# Declared pilot run / Rodada declarada do piloto.
#
# (pt) A configuração limita consultas antes da primeira chamada. Descoberta,
#      seleção e exportação compartilham um orçamento e só gravam fora do git.
# (en) Validate the declared queries before any request. Discovery, selection,
#      and export share a budget and write only to the external data root.

radar_ler_rodada <- function(path, seeds_path = file.path(radar_repository_root(), "config", "seeds.yml")) {
  rodada <- yaml::yaml.load(readr::read_file(path, locale = readr::locale(encoding = "UTF-8")))
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  required <- c("run_id", "fontes", "max_tentativas", "max_documentos",
                "max_caracteres_documento", "max_paginas", "github", "huggingface",
                "gitlab", "enriquecimento")
  if (!is.list(rodada) || !all(required %in% names(rodada)) ||
      !grepl("^[A-Za-z0-9_-]+$", rodada$run_id))
    stop("Arquivo de rodada incompleto ou run_id inválido.", call. = FALSE)
  radar_novo_orcamento(rodada$max_tentativas, rodada$max_documentos)
  if (!identical(as.integer(rodada$max_caracteres_documento), 24000L) ||
      !setequal(rodada$fontes, c("github", "huggingface", "gitlab")) ||
      !setequal(names(rodada$max_paginas),
                c("github_conta", "github_topico", "huggingface", "gitlab")) ||
      !all(unlist(rodada$max_paginas) == 1L) ||
      !identical(rodada$enriquecimento$estratificacao, "proporcional"))
    stop("Parâmetros de fontes, páginas ou corte da rodada são inválidos.", call. = FALSE)
  gh_accounts <- purrr::map_chr(seeds$contas$github, "conta")
  hf_accounts <- hf_seed_accounts(seeds)
  if (!all(rodada$github$contas %in% gh_accounts) ||
      !all(rodada$huggingface$contas %in% hf_accounts) ||
      !all(rodada$gitlab$termos %in% gitlab_seed_terms(seeds)) ||
      !all(rodada$github$termos_semente %in% github_seed_terms(seeds)) ||
      !identical(rodada$huggingface$tipo, "models") ||
      !isTRUE(rodada$huggingface$full) ||
      any(c(rodada$github$por_pagina, rodada$huggingface$por_pagina,
            rodada$gitlab$por_pagina) > 100L))
    stop("Consultas da rodada não correspondem às sementes e aos limites aprovados.", call. = FALSE)
  rodada
}

coletar_github_rodada <- function(rodada, seeds_path, root, budget, request_fn = NULL) {
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  account_rows <- lapply(rodada$github$contas, function(account) {
    payload <- github_request(paste0("GET /users/", account, "/repos"),
                              list(type = "owner", per_page = 100L, page = 1L),
                              root, request_fn, budget, public_only = TRUE)
    bind_github_items(list(payload))
  })
  topic_rows <- lapply(rodada$github$topicos, function(topic) {
    payload <- github_request("GET /search/repositories",
      list(q = paste0("topic:", topic, " is:public"), per_page = 100L,
           page = 1L, sort = "updated", order = "desc"),
      root, request_fn, budget, public_only = TRUE)
    bind_github_items(list(payload$items %||% list()))
  })
  # Exact known positives are fetched even if a topic/account listing omits them.
  # (pt) As duas sementes exatas não dependem da ordenação das listagens.
  seed_urls <- unlist(lapply(seeds$gabarito, function(entry) {
    artifact_names <- vapply(entry$artefatos, function(artifact)
      sub(".*/", "", artifact$url), character(1))
    if (!(entry$nome %in% rodada$github$termos_semente) &&
        !any(artifact_names %in% rodada$github$termos_semente)) return(character())
    vapply(entry$artefatos, function(artifact) {
      if (identical(artifact$plataforma, "github")) artifact$url else NA_character_
    }, character(1))
  }), use.names = FALSE)
  seed_urls <- unique(stats::na.omit(seed_urls))
  seed_rows <- lapply(seed_urls, function(url) {
    repo <- sub("^https://github.com/", "", url)
    bind_github_items(list(list(github_request(
      paste0("GET /repos/", repo), list(), root, request_fn, budget, public_only = TRUE
    ))))
  })
  result <- dplyr::bind_rows(c(seed_rows, account_rows, topic_rows)) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE) |>
    aplicar_ids_sementes(seeds)
  attr(result, "radar_metadata") <- list(
    provider = "github", account_count = length(rodada$github$contas),
    topic_count = length(rodada$github$topicos), seed_count = length(seed_urls),
    pages_requested = length(rodada$github$contas) + length(rodada$github$topicos)
  )
  result
}

coletar_hf_rodada <- function(rodada, seeds_path, root, budget, request_fn = NULL) {
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  checks <- list()
  rows <- lapply(rodada$huggingface$contas, function(account) {
    payload <- tryCatch(hf_api_page("models",
      list(author = account, limit = 100L, full = "true"), root, request_fn, budget),
      http_error_404 = function(error) NULL)
    if (is.null(payload)) {
      checks[[account]] <<- "inexistente"
      return(hf_normalize_items(list(), "models"))
    }
    items <- if (!is.null(payload$.radar_items)) payload$.radar_items else
      if (!is.null(payload$items)) payload$items else payload
    if (!length(items)) {
      # An empty listing alone cannot prove account absence. Check the public
      # account endpoint and report 404 explicitly, keeping other errors fatal.
      # (pt) A listagem vazia exige conferir a conta; só 404 prova inexistência.
      exists <- tryCatch({
        hf_api_page(paste0("users/", account, "/overview"), list(),
                    root, request_fn, budget)
        TRUE
      }, http_error_404 = function(error) FALSE)
      checks[[account]] <<- if (exists) "sem_modelos" else "inexistente"
    } else {
      checks[[account]] <<- "com_modelos"
    }
    hf_normalize_items(items, "models")
  })
  result <- dplyr::bind_rows(rows) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE) |>
    aplicar_ids_sementes(seeds)
  attr(result, "radar_metadata") <- list(provider = "huggingface", contas = checks,
                                          pages_requested = length(rodada$huggingface$contas))
  result
}

radar_manifesto_piloto <- function(rodada, budget, counts, corpus, hf_checks = list(),
                                   failure = NULL) {
  status <- as.list(budget$status_http)
  list(
    run_id = rodada$run_id,
    timestamp_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    janela = list(inicio = NA_character_, fim = as.character(Sys.Date())),
    collector_commit = tryCatch(trimws(system2("git", c("rev-parse", "HEAD"), stdout = TRUE)),
                                error = function(error) NA_character_),
    collector_version = "piloto-1", codebook_version = NA_character_,
    decifra_commit = NA_character_, decifra_version = NA_character_,
    consultas = rodada, status_http = status,
    totais = c(counts, list(corpus = nrow(corpus),
                            documentos_cortados = sum(corpus$text_truncated))),
    paginas_lidas = sum(vapply(budget$ledger, function(call) {
      (call$provider == "github" &&
         (grepl("^GET /users/", call$resource) ||
          identical(call$resource, "GET /search/repositories"))) ||
        (call$provider == "huggingface" && identical(call$resource, "models")) ||
        (call$provider == "gitlab" && identical(call$resource, "GET /projects"))
    }, logical(1))),
    tentativas_usadas = budget$tentativas_reservadas,
    documentos_selecionados = length(budget$documentos),
    contas_hf = hf_checks,
    falhas = c(budget$falhas, if (!is.null(failure)) list(list(message = failure)) else list()),
    cache_ref = file.path("bbsia-radar", "api")
  )
}

# (pt) Metadados dos candidatos selecionados, sem o texto do README: servem à
#      estimativa de TRL e à planilha do formulário (R/planilha_bbsia.R).
# (en) Selected candidates' metadata, without README text.
radar_tabela_candidatos <- function(docs) {
  keep <- intersect(c("id", "platform", "kind", "name", "full_name", "url", "owner", "description",
                      "language", "stars", "downloads", "license", "created_at", "pushed_at",
                      "updated_at", "fork", "archived", "pipeline_tag", "readme_status", "sha"),
                    names(docs))
  table <- docs[keep]
  table$id <- purrr::pmap_chr(
    list(docs$platform, docs$id, if ("kind" %in% names(docs)) docs$kind else rep(NA_character_, nrow(docs))),
    radar_artifact_id)
  table$readme_chars <- ifelse(is.na(docs$readme), 0L, nchar(docs$readme, type = "chars"))
  table
}

# (pt) Refaz descoberta, seleção e leitura de uma rodada já executada usando
#      SÓ o cache: toda função de requisição falha de propósito, então uma
#      resposta ausente vira erro em vez de chamada nova às APIs. Para na
#      seleção (o texto já está no corpus) e não grava manifesto nem corpus. Serve para recuperar metadados de rodadas
#      anteriores a radar_tabela_candidatos().
# (en) Cache-only replay of a finished round; any cache miss is an error.
radar_reconstruir_rodada <- function(path, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")) {
  offline <- function(...) stop("Resposta ausente do cache; a reconstrução não chama as APIs.", call. = FALSE)
  rodada <- radar_ler_rodada(path)
  radar_validate_cache_root(root)
  seeds_path <- file.path(radar_repository_root(), "config", "seeds.yml")
  budget <- radar_novo_orcamento(rodada$max_tentativas, rodada$max_documentos)
  github <- coletar_github_rodada(rodada, seeds_path, root, budget, offline)
  hf <- coletar_hf_rodada(rodada, seeds_path, root, budget, offline)
  gitlab <- coletar_gitlab(seeds_path, root, offline, rodada$gitlab$termos, budget)
  candidates <- dplyr::bind_rows(github, hf, gitlab)
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  priority_urls <- unlist(lapply(seeds$gabarito, function(entry)
    vapply(entry$artefatos, function(artifact) artifact$url, character(1))), use.names = FALSE)
  # Stops at the selection: README text is already in the corpus, and the
  # GitLab README check is refreshed on every run by design (never cache-only).
  selected <- selecionar_enriquecimento_rodada(candidates, rodada$max_documentos, priority_urls)
  selected$readme <- NA_character_
  selected
}

radar_executar_rodada <- function(path, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                                 request_github_fn = NULL, request_hf_fn = NULL,
                                 request_gitlab_fn = NULL) {
  rodada <- radar_ler_rodada(path)
  radar_validate_cache_root(root)
  seeds_path <- file.path(radar_repository_root(), "config", "seeds.yml")
  manifest_path <- file.path(radar_cache_root(root), "bbsia-radar", "runs",
                             paste0(rodada$run_id, ".json"))
  if (file.exists(manifest_path)) stop("Manifesto de rodada já existe; não sobrescrever histórico.", call. = FALSE)
  budget <- radar_novo_orcamento(rodada$max_tentativas, rodada$max_documentos)
  counts <- list(github = 0L, huggingface = 0L, gitlab = 0L)
  empty <- montar_corpus(artifact_ids = TRUE, max_chars = 24000L)
  hf_checks <- list()
  result <- tryCatch({
    github <- coletar_github_rodada(rodada, seeds_path, root, budget, request_github_fn)
    counts$github <- nrow(github)
    hf <- coletar_hf_rodada(rodada, seeds_path, root, budget, request_hf_fn)
    counts$huggingface <- nrow(hf)
    hf_checks <- attr(hf, "radar_metadata")$contas
    gitlab <- coletar_gitlab(seeds_path, root, request_gitlab_fn,
                              rodada$gitlab$termos, budget)
    counts$gitlab <- nrow(gitlab)
    candidates <- dplyr::bind_rows(github, hf, gitlab)
    seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
    priority_urls <- unlist(lapply(seeds$gabarito, function(entry)
      vapply(entry$artefatos, function(artifact) artifact$url, character(1))), use.names = FALSE)
    selected <- selecionar_enriquecimento_rodada(candidates, rodada$max_documentos, priority_urls)
    enriched <- coletar_readmes_exploratorios(
      candidates, root, request_github_fn, request_hf_fn, priority_urls, budget,
      request_gitlab_fn, selected_repositories = selected
    )
    docs <- enriched$documents
    corpus <- montar_corpus(
      github = docs[docs$platform == "github", , drop = FALSE],
      huggingface = docs[docs$platform == "huggingface", , drop = FALSE],
      gitlab = docs[docs$platform == "gitlab", , drop = FALSE],
      artifact_ids = TRUE, max_chars = rodada$max_caracteres_documento
    )
    export <- file.path(radar_cache_root(root), "bbsia-radar", "exports",
                        paste0(rodada$run_id, "-corpus.csv"))
    if (file.exists(export)) stop("Corpus da rodada já existe; não sobrescrever.", call. = FALSE)
    salvar_corpus_decifra(corpus, export, root)
    readr::write_csv(radar_tabela_candidatos(docs),
                     sub("-corpus\\.csv$", "-candidatos.csv", export), na = "")
    manifesto <- radar_manifesto_piloto(rodada, budget, counts, corpus, hf_checks)
    radar_salvar_manifesto_rodada(manifesto, root)
    list(corpus = corpus, manifesto = manifesto, corpus_path = export,
         manifest_path = manifest_path)
  }, error = function(error) {
    manifesto <- radar_manifesto_piloto(rodada, budget, counts, empty, hf_checks,
                                        conditionMessage(error))
    radar_salvar_manifesto_rodada(manifesto, root)
    stop(error)
  })
  result
}
