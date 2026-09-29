# Longitudinal observation helpers / Funções para observações longitudinais.
#
# (pt) Estas funções são puras até o manifesto ser gravado. Elas não consultam
#      APIs, não classificam candidatos e não publicam dados. A identidade da
#      solução continua uma decisão de curadoria; a plataforma identifica só o
#      artefato. Ausência numa busca e HTTP 404 não significam encerramento.
# (en) These functions have no network or publication side effects. Platform
#      IDs identify artifacts, while solution identity requires curation. A
#      missing search hit or HTTP 404 is never treated as confirmed closure.

radar_artifact_id <- function(platform, id, kind = NULL) {
  if (length(platform) != 1L || is.na(platform) ||
      length(id) != 1L || is.na(id) || !nzchar(trimws(as.character(id)))) {
    stop("Plataforma e identificador do artefato são obrigatórios.", call. = FALSE)
  }
  platform <- as.character(platform)
  id <- if (is.numeric(id)) format(id, scientific = FALSE, trim = TRUE) else as.character(id)
  if (!platform %in% c("github", "gitlab", "huggingface")) {
    stop("Plataforma desconhecida.", call. = FALSE)
  }
  if (platform %in% c("github", "gitlab")) {
    if (!grepl("^[0-9]+$", id)) {
      stop("GitHub/GitLab exigem o ID numérico da API, não a URL.", call. = FALSE)
    }
    return(paste(platform, id, sep = ":"))
  }
  if (length(kind) != 1L || is.na(kind) || !kind %in% c("models", "datasets", "spaces")) {
    stop("Hugging Face exige kind: models, datasets ou spaces.", call. = FALSE)
  }
  if (!grepl("^[^/[:space:]]+/[^/[:space:]]+$", id)) {
    stop("Hugging Face exige repo_id namespace/nome; renomes vão no mapa de aliases.", call. = FALSE)
  }
  paste("huggingface", kind, id, sep = ":")
}

radar_seed_ids <- function(seeds_path = "config/seeds.yml") {
  seeds <- yaml::yaml.load(readr::read_file(
    seeds_path, locale = readr::locale(encoding = "UTF-8")))
  ids <- purrr::map_chr(seeds$gabarito %||% list(), "id_solucao")
  if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids)) {
    stop("config/seeds.yml contém id_solucao ausente ou duplicado.", call. = FALSE)
  }
  ids
}

radar_propor_vinculos <- function(artifacts, seed_ids = radar_seed_ids()) {
  # (pt) A migração mantém IDs de sementes já curadas. Para cada URL ainda usada
  #      como identidade provisória, propõe uma chave sem URL derivada do ID da
  #      plataforma. Isto não deduplica soluções: fusões exigem decisão humana.
  # (en) Preserve curated seed IDs. Derive a URL-free provisional solution ID
  #      from the platform ID for each remaining artifact. This is a proposal,
  #      not an automatic cross-platform entity resolution.
  required <- c("platform", "id", "kind", "url", "solution_id")
  if (!all(required %in% names(artifacts))) {
    stop("Artefatos exigem platform, id, kind, url e solution_id.", call. = FALSE)
  }
  artifact_ids <- vapply(seq_len(nrow(artifacts)), function(i) {
    radar_artifact_id(artifacts$platform[[i]], artifacts$id[[i]], artifacts$kind[[i]])
  }, character(1))
  if (anyDuplicated(artifact_ids)) {
    stop("ID da plataforma duplicado; revisar antes da migração.", call. = FALSE)
  }
  previous <- as.character(artifacts$solution_id)
  curated <- !is.na(previous) & previous %in% seed_ids
  provisional <- paste0("s-", vapply(artifact_ids, function(id) {
    substr(digest::digest(id, algo = "sha256", serialize = FALSE), 1L, 20L)
  }, character(1)))
  proposed <- ifelse(curated, previous, provisional)
  tibble::tibble(
    artifact_id = artifact_ids,
    solution_id_proposto = as.character(unname(proposed)),
    identidade_status = as.character(ifelse(curated, "curado_semente", "provisorio")),
    url_observada = as.character(artifacts$url),
    solution_id_anterior = previous
  )
}

radar_validar_observacoes <- function(observacoes) {
  required <- c("artifact_id", "content_hash", "status")
  if (!all(required %in% names(observacoes))) {
    stop("Observações exigem artifact_id, content_hash e status.", call. = FALSE)
  }
  if (anyNA(observacoes$artifact_id) || any(!nzchar(observacoes$artifact_id)) ||
      anyDuplicated(observacoes$artifact_id)) {
    stop("artifact_id deve ser único e não vazio por rodada.", call. = FALSE)
  }
  if (anyNA(observacoes$status) || any(!observacoes$status %in% c("ok", "http_404"))) {
    stop("status deve ser ok ou http_404; outros erros vão no manifesto.", call. = FALSE)
  }
  missing_hash <- observacoes$status == "ok" &
    (is.na(observacoes$content_hash) | !nzchar(observacoes$content_hash))
  if (any(missing_hash)) {
    stop("Observação ok exige hash da revisão do conteúdo efetivamente lido.", call. = FALSE)
  }
  invisible(observacoes)
}

radar_eventos_rodada <- function(run_id, atual, anterior = NULL) {
  if (length(run_id) != 1L || is.na(run_id) ||
      !grepl("^[A-Za-z0-9_-]+$", run_id)) {
    stop("run_id deve ser um identificador seguro para arquivo.", call. = FALSE)
  }
  if (is.null(anterior)) anterior <- list()
  if (is.data.frame(anterior)) anterior <- list(anterior)
  if (!is.list(anterior) || any(!vapply(anterior, is.data.frame, logical(1)))) {
    stop("anterior deve ser uma observação ou lista cronológica de observações.", call. = FALSE)
  }
  radar_validar_observacoes(atual)
  invisible(lapply(anterior, radar_validar_observacoes))
  radar_validar_ordem_rodadas(c(anterior, list(atual)))
  prior_ids <- unique(unlist(lapply(anterior, function(run) run$artifact_id), use.names = FALSE))
  ids <- union(prior_ids, atual$artifact_id)
  if (!length(ids)) {
    return(tibble::tibble(run_id = character(), artifact_id = character(),
                          evento = character(), content_hash = character(),
                          conteudo_alterado = logical(), rodadas_ausente = integer()))
  }
  latest <- if (length(anterior)) anterior[[length(anterior)]] else
    tibble::tibble(artifact_id = character(), content_hash = character(), status = character())
  current_index <- match(ids, atual$artifact_id)
  event <- vapply(seq_along(ids), function(i) {
    known <- NULL
    if (length(anterior)) for (run in rev(anterior)) {
      index <- match(ids[[i]], run$artifact_id)
      if (!is.na(index)) { known <- run[index, , drop = FALSE]; break }
    }
    now <- current_index[[i]]
    if (is.na(now)) return("ausente_da_busca")
    if (identical(atual$status[[now]], "http_404")) return("http_404")
    if (is.null(known)) return("novo")
    if (is.na(match(ids[[i]], latest$artifact_id)) ||
        identical(known$status[[1]], "http_404")) return("reapareceu")
    if (identical(known$content_hash[[1]], atual$content_hash[[now]])) {
      return("inalterado")
    }
    "alterado"
  }, character(1))
  hash <- vapply(current_index, function(i) {
    if (is.na(i)) return(NA_character_)
    as.character(atual$content_hash[[i]])
  }, character(1))
  # (pt) `reapareceu` diz que o artefato voltou, mas não se mudou enquanto
  #      esteve fora. `conteudo_alterado` compara com o último conteúdo lido
  #      (NA quando não há o que comparar: artefato novo, ausente ou 404 agora).
  # (en) Compare with the last content actually read, whatever the event.
  last_hash <- vapply(ids, function(id) {
    for (run in rev(anterior)) {
      index <- match(id, run$artifact_id)
      if (!is.na(index) && identical(run$status[[index]], "ok")) return(run$content_hash[[index]])
    }
    NA_character_
  }, character(1), USE.NAMES = FALSE)
  now_ok <- !is.na(current_index) & vapply(current_index, function(i)
    !is.na(i) && identical(atual$status[[i]], "ok"), logical(1))
  changed <- ifelse(now_ok & !is.na(last_hash), hash != last_hash, NA)
  # (pt) Rodadas seguidas, até a atual, sem conteúdo lido: ausência da busca e
  #      404 contam igual, porque em ambas o radar não viu o artefato. A
  #      contagem para na última rodada em que ele foi lido com sucesso.
  # (en) Consecutive rounds, up to now, in which the artifact was not read.
  runs <- c(anterior, list(atual))
  missing_streak <- vapply(ids, function(id) {
    streak <- 0L
    for (run in rev(runs)) {
      index <- match(id, run$artifact_id)
      if (!is.na(index) && identical(run$status[[index]], "ok")) break
      streak <- streak + 1L
    }
    streak
  }, integer(1), USE.NAMES = FALSE)
  tibble::tibble(run_id = run_id, artifact_id = ids, evento = event, content_hash = hash,
                 conteudo_alterado = as.logical(changed), rodadas_ausente = missing_streak)
}

# (pt) Com `observado_em` em todas as rodadas, a lista precisa estar em ordem
#      cronológica: a comparação usa a última rodada conhecida, e uma lista
#      embaralhada trocaria "alterado" por "inalterado" sem aviso. Sem
#      `observado_em`, vale a ordem da lista, como antes.
# (en) When every run carries `observado_em`, runs must not overlap in time
#      and must be listed oldest first.
radar_validar_ordem_rodadas <- function(runs) {
  has_time <- vapply(runs, function(run) "observado_em" %in% names(run) && nrow(run) > 0L,
                     logical(1))
  if (!any(has_time)) return(invisible(TRUE))
  timed <- runs[has_time]
  parse <- function(x) as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
  bounds <- lapply(timed, function(run) {
    times <- parse(run$observado_em)
    if (anyNA(times)) stop("observado_em deve estar em UTC, no formato AAAA-MM-DDTHH:MM:SSZ.", call. = FALSE)
    range(times)
  })
  for (i in seq_along(bounds)[-1]) {
    if (bounds[[i]][[1]] <= bounds[[i - 1L]][[2]]) {
      stop("As rodadas precisam estar em ordem cronológica, da mais antiga para a atual.", call. = FALSE)
    }
  }
  invisible(TRUE)
}

radar_content_hash <- function(platform, revision_sha, text) {
  if (length(platform) != 1L || !platform %in% c("github", "gitlab", "huggingface") ||
      length(revision_sha) != 1L || is.na(revision_sha) ||
      !grepl("^[0-9a-f]{40}([0-9a-f]{24})?$", revision_sha) ||
      length(text) != 1L || is.na(text)) {
    stop("Exige plataforma, SHA imutável da revisão lida e texto.", call. = FALSE)
  }
  paste(platform, revision_sha,
        digest::digest(enc2utf8(text), algo = "sha256", serialize = FALSE), sep = ":")
}

radar_aliases <- function(aliases) {
  required <- c("artifact_id", "url_antiga", "url_atual")
  if (!all(required %in% names(aliases)) ||
      anyNA(aliases[, required]) || anyDuplicated(aliases$url_antiga)) {
    stop("Mapa de aliases exige artifact_id e URLs únicas, sem ausências.", call. = FALSE)
  }
  tibble::as_tibble(aliases[, required, drop = FALSE])
}

radar_ler_aliases <- function(path = "config/aliases.yml") {
  source <- yaml::yaml.load(readr::read_file(
    path, locale = readr::locale(encoding = "UTF-8")))
  rows <- source$aliases %||% list()
  if (!length(rows)) return(tibble::tibble(
    artifact_id = character(), url_antiga = character(), url_atual = character()))
  radar_aliases(purrr::map_dfr(rows, tibble::as_tibble_row))
}

radar_salvar_manifesto_rodada <- function(manifesto,
                                          root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")) {
  # (pt) O manifesto bruto permanece no cache externo. A seleção revisada para
  #      data/ é uma etapa separada, com autorização específica de publicação.
  # (en) Raw run metadata remains in the external cache; publication is a
  #      separate reviewed step, not a side effect of a collector run.
  required <- c("run_id", "timestamp_utc", "janela", "collector_commit",
                "collector_version", "codebook_version", "decifra_commit",
                "decifra_version", "consultas", "status_http", "totais",
                "paginas_lidas", "falhas", "cache_ref")
  if (!is.list(manifesto) || !all(required %in% names(manifesto))) {
    stop("Manifesto incompleto: faltam campos obrigatórios da rodada.", call. = FALSE)
  }
  run_id <- manifesto$run_id
  if (length(run_id) != 1L || is.na(run_id) || !grepl("^[A-Za-z0-9_-]+$", run_id)) {
    stop("run_id inválido.", call. = FALSE)
  }
  radar_validate_cache_root(root)
  path <- file.path(radar_cache_root(root), "bbsia-radar", "runs", paste0(run_id, ".json"))
  if (file.exists(path)) stop("Manifesto de rodada já existe; não sobrescrever histórico.", call. = FALSE)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(manifesto, path, auto_unbox = TRUE, pretty = TRUE, null = "null")
  invisible(path)
}
