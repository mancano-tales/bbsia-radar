# Public GitHub discovery / Descoberta pública no GitHub.
#
# (pt) Este módulo usa somente a API REST oficial. O modo exploratório exige
#      até dois termos explícitos das sementes, solicita uma página por termo,
#      não enumera contas e registra contagens e resultados incompletos. Uma
#      lista curada pode acrescentar apenas soluções já marcadas como brasileiras
#      no gabarito, consultadas individualmente. Cada resposta bruta é cacheada
#      antes da transformação e usa orçamento compartilhado com HF e README.
#      Chamadas são anônimas e não têm retentativa automática.
# (en) This module uses only the official REST API. Exploratory mode requires
#      up to two explicit seed terms, requests one page per term, never crawls
#      accounts, and records result counts and incomplete responses. Raw
#      responses are cached before transformation and share a request budget
#      with HF and README enrichment. A curated list may add only solutions
#      already tagged as Brazilian in the gold set, fetched individually.
#      Requests are anonymous and automatic retries are disabled.

github_request <- function(path, query = list(), root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                           request_fn = NULL, budget, public_only = FALSE) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  key <- list(
    provider = "github", path = path, query = query,
    public_only = public_only
  )
  payload <- radar_cached(key, function() {
    radar_reservar_requisicao(budget, "github", path)
    if (!is.null(request_fn)) {
      payload <- request_fn(path, query)
    } else {
      # Public endpoints work without credentials. A general GITHUB_PAT is
      # never inherited (it is usually broad and shared with other tools).
      # Only BBSIA_RADAR_GITHUB_TOKEN is sent: a fine-grained token created
      # for this project with public-repositories read-only access, which
      # only raises the rate limit and cannot read private content. Every
      # listing still passes github_validar_itens_publicos().
      request <- github_http_request(path, query)
      response <- httr2::req_perform(request)
      status <- httr2::resp_status(response)
      if (is.na(status) || status < 200L || status >= 300L) {
        body <- tryCatch(httr2::resp_body_json(response, simplifyVector = FALSE),
                         error = function(error) httr2::resp_body_string(response))
        payload <- list(.radar_http_status = status, .radar_http_body = body)
      } else {
        payload <- httr2::resp_body_json(response, simplifyVector = FALSE)
      }
    }
    radar_registrar_status(budget, "github", radar_status_resposta(payload), path)
    if (isTRUE(public_only) && is.null(payload$.radar_http_status)) {
      repo_metadata <- grepl("^GET /repos/[^/]+/[^/]+$", path)
      expected_repo <- if (repo_metadata) sub("^GET /repos/", "", path) else NULL
      github_validar_itens_publicos(
        payload, require_explicit_repo = repo_metadata, expected_repo = expected_repo
      )
    }
    payload
  }, root = root)
  if (is.list(payload) && !is.null(payload$.radar_http_status)) {
    radar_verificar_status_http(payload$.radar_http_status, "GitHub", path)
  }
  payload
}

github_http_request <- function(path, query = list()) {
  endpoint <- sub("^GET /", "https://api.github.com/", path)
  request <- httr2::request(endpoint) |>
    httr2::req_user_agent("bbsia-radar/0.1.0 (public research; see repository)") |>
    httr2::req_headers(
      Accept = "application/vnd.github+json",
      `X-GitHub-Api-Version` = "2022-11-28"
    ) |>
    httr2::req_options(followlocation = FALSE) |>
    httr2::req_error(is_error = function(response) FALSE) |>
    httr2::req_timeout(30)
  token <- Sys.getenv("BBSIA_RADAR_GITHUB_TOKEN", "")
  if (nzchar(token)) request <- httr2::req_auth_bearer_token(request, token)
  do.call(httr2::req_url_query, c(list(request), query))
}

github_search_window <- function(term, start_date, end_date, root, request_fn = NULL, budget) {
  q <- paste(term, "is:public", paste0("created:", start_date, "..", end_date))
  first <- github_request(
    "GET /search/repositories",
    list(q = q, per_page = 100, page = 1, sort = "updated", order = "desc"),
    root, request_fn, budget, public_only = TRUE
  )
  items <- first$items %||% list()
  total <- as.integer(first$total_count %||% length(items))
  returned <- length(items)
  partial <- isTRUE(first$incomplete_results) || (!is.na(total) && total > returned)
  summary <- tibble::tibble(
    term = term,
    query = q,
    page = 1L,
    per_page = 100L,
    sort = "updated",
    order = "desc",
    total_count = total,
    returned = returned,
    incomplete_results = isTRUE(first$incomplete_results),
    partial = partial
  )
  result <- bind_github_items(list(items))
  attr(result, "search_summary") <- summary
  result
}

github_validar_itens_publicos <- function(payload, require_explicit_repo = FALSE,
                                          expected_repo = NULL) {
  items <- payload$items %||% if (is.null(names(payload))) payload else list()
  # A repository endpoint returns one object rather than a Search envelope.
  # Require its visibility flag explicitly so an incomplete response can never
  # be treated as public merely because the field is absent.
  # (pt) O endpoint de um repositório retorna um objeto, não o envelope de
  #      busca. Exigimos o campo de visibilidade para não presumir que uma
  #      resposta incompleta seja pública.
  if (isTRUE(require_explicit_repo) &&
      (is.null(payload$full_name) || is.null(payload$private) ||
       !identical(payload$private, FALSE))) {
    stop("GitHub não confirmou que o repositório-semente é público; a resposta não será cacheada.",
         call. = FALSE)
  }
  if (!is.null(expected_repo) &&
      !identical(tolower(payload$full_name), tolower(expected_repo))) {
    stop("GitHub retornou outro repositório-semente; a resposta não será cacheada.", call. = FALSE)
  }
  if (is.list(items) && length(items) &&
      any(purrr::map_lgl(items, ~ isTRUE(.x$private)))) {
    stop("GitHub Search retornou um repositório privado; a resposta não será cacheada.", call. = FALSE)
  }
  invisible(payload)
}

github_validar_termos <- function(search_terms, seeds) {
  if (is.null(search_terms) || !length(search_terms) || anyNA(search_terms) ||
      any(!nzchar(trimws(search_terms)))) {
    stop("Informe explicitamente um ou dois termos de busca derivados das sementes.", call. = FALSE)
  }
  if (length(search_terms) > 2L || anyDuplicated(search_terms)) {
    stop("A busca exploratória aceita no máximo dois termos distintos.", call. = FALSE)
  }
  allowed <- github_seed_terms(seeds)
  if (!all(search_terms %in% allowed)) {
    stop("Cada termo precisa corresponder a um nome já presente em config/seeds.yml.", call. = FALSE)
  }
  unname(search_terms)
}

bind_github_items <- function(pages) {
  items <- unlist(pages, recursive = FALSE)
  if (!length(items)) {
    return(tibble::tibble(
      platform = character(), id = character(), full_name = character(), name = character(),
      description = character(), url = character(), owner = character(), language = character(),
      stars = integer(), updated_at = character(), topics = list(), readme = character(),
      license = character(), created_at = character(), pushed_at = character(),
      fork = logical(), archived = logical(), owner_type = character(), homepage = character()
    ))
  }
  # Explicit field allow-list prevents accidental ingestion of API fields such
  # as public email if GitHub changes its payload in the future.
  # (pt) license, created_at, pushed_at, fork e archived alimentam a estimativa
  #      de maturidade (R/trl.R); já vêm nas respostas de listagem e busca.
  tibble::tibble(
    platform = "github",
    id = purrr::map_chr(items, ~ {
      value <- .x$id %||% NA_character_
      if (is.numeric(value)) format(value, scientific = FALSE, trim = TRUE) else as.character(value)
    }),
    full_name = purrr::map_chr(items, ~ .x$full_name %||% NA_character_),
    name = purrr::map_chr(items, ~ .x$name %||% NA_character_),
    description = purrr::map_chr(items, ~ .x$description %||% NA_character_),
    url = purrr::map_chr(items, ~ .x$html_url %||% NA_character_),
    owner = purrr::map_chr(items, ~ .x$owner$login %||% NA_character_),
    language = purrr::map_chr(items, ~ .x$language %||% NA_character_),
    stars = purrr::map_int(items, ~ as.integer(.x$stargazers_count %||% 0L)),
    updated_at = purrr::map_chr(items, ~ .x$updated_at %||% NA_character_),
    topics = purrr::map(items, ~ unlist(.x$topics %||% character(), use.names = FALSE)),
    readme = NA_character_,
    license = purrr::map_chr(items, ~ .x$license$spdx_id %||% NA_character_),
    created_at = purrr::map_chr(items, ~ .x$created_at %||% NA_character_),
    pushed_at = purrr::map_chr(items, ~ .x$pushed_at %||% NA_character_),
    fork = purrr::map_lgl(items, ~ isTRUE(.x$fork)),
    archived = purrr::map_lgl(items, ~ isTRUE(.x$archived)),
    owner_type = purrr::map_chr(items, ~ .x$owner$type %||% NA_character_),
    homepage = purrr::map_chr(items, ~ {
      value <- .x$homepage %||% NA_character_
      if (is.na(value) || !nzchar(value)) NA_character_ else value
    })
  )
}

# (pt) Contexto que o README não traz, para o Decifra decidir melhor e para o
#      TRL: número de releases e de contribuidores (só a contagem, nunca os
#      nomes; até 100, uma página) e, quando o dono é ORGANIZAÇÃO, nome,
#      descrição, site e localização declarados pela organização. De pessoa
#      física nada é lido além do login público (regra LGPD do AGENTS.md).
#      Lista explícita de campos: e-mail da organização nunca é guardado.
# (en) Counts only for releases/contributors; organisation profile only for
#      organisation owners, with an explicit field allow-list.
coletar_contexto_github <- function(repositories, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                                    request_fn = NULL, budget) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  contar <- function(path) {
    payload <- tryCatch(
      github_request(path, list(per_page = 100L, page = 1L), root, request_fn, budget, public_only = TRUE),
      error = function(error) if (inherits(error, "http_error_404")) NULL else stop(error))
    if (is.null(payload)) NA_integer_ else length(payload)
  }
  repositories$releases <- purrr::map_int(repositories$full_name, function(full_name) {
    if (is.na(full_name)) NA_integer_ else contar(paste0("GET /repos/", full_name, "/releases"))
  })
  repositories$contribuidores <- purrr::map_int(repositories$full_name, function(full_name) {
    if (is.na(full_name)) NA_integer_ else contar(paste0("GET /repos/", full_name, "/contributors"))
  })
  orgs <- unique(stats::na.omit(repositories$owner[repositories$owner_type %in% "Organization"]))
  perfis <- purrr::map(stats::setNames(orgs, orgs), function(login) {
    payload <- tryCatch(github_request(paste0("GET /orgs/", login), list(), root, request_fn, budget,
                                       public_only = TRUE),
                        error = function(error) if (inherits(error, "http_error_404")) NULL else stop(error))
    if (is.null(payload)) return(NULL)
    list(nome = payload$name %||% NA_character_, descricao = payload$description %||% NA_character_,
         site = payload$blog %||% NA_character_, local = payload$location %||% NA_character_)
  })
  campo <- function(field) vapply(seq_len(nrow(repositories)), function(i) {
    if (!(repositories$owner_type[[i]] %in% "Organization")) return(NA_character_)
    perfil <- perfis[[repositories$owner[[i]]]]
    value <- if (is.null(perfil)) NA_character_ else perfil[[field]]
    if (is.null(value) || is.na(value) || !nzchar(value)) NA_character_ else as.character(value)
  }, character(1))
  repositories$org_nome <- campo("nome")
  repositories$org_descricao <- campo("descricao")
  repositories$org_site <- campo("site")
  repositories$org_local <- campo("local")
  repositories
}

github_seed_terms <- function(seeds) {
  radar_seed_search_terms(seeds)
}

github_sementes_lista_brasileiras <- function(seeds, list_name) {
  # Only solutions explicitly tagged as Brazilian in the author's curated
  # list are included. The list itself is global, so we deliberately do not
  # expand this to its other entries or crawl its repository.
  # (pt) A lista é global. Selecionamos apenas as soluções que já têm a
  #      marcação brasileira registrada no gabarito, sem percorrer as demais.
  known_lists <- purrr::map_chr(seeds$listas %||% list(), ~ .x$nome)
  if (length(list_name) != 1L || is.na(list_name) || !(list_name %in% known_lists)) {
    stop("A lista precisa corresponder a um nome já registrado em config/seeds.yml.", call. = FALSE)
  }
  entries <- seeds$gabarito %||% list()
  selected <- purrr::keep(entries, function(entry) {
    source <- entry$fonte %||% ""
    startsWith(source, paste0(list_name, " (tag brazil):"))
  })
  rows <- purrr::map_dfr(selected, function(entry) {
    github_artifacts <- purrr::keep(entry$artefatos %||% list(),
                                    ~ identical(.x$plataforma, "github"))
    if (!length(github_artifacts)) return(tibble::tibble())
    purrr::map_dfr(github_artifacts, function(artifact) {
      url <- sub("/$", "", trimws(artifact$url %||% ""))
      match <- regmatches(url, regexec(
        "^https://github\\.com/([A-Za-z0-9_.-]+)/([A-Za-z0-9_.-]+)$",
        url, perl = TRUE
      ))[[1]]
      if (length(match) != 3L) {
        stop("A semente brasileira precisa usar uma URL canônica de repositório GitHub.",
             call. = FALSE)
      }
      tibble::tibble(
        solution_id = as.character(entry$id_solucao),
        seed_source = as.character(entry$fonte),
        url = url,
        full_name = paste(match[[2]], match[[3]], sep = "/")
      )
    })
  })
  if (!nrow(rows)) {
    stop("A lista não tem soluções GitHub brasileiras marcadas no gabarito.", call. = FALSE)
  }
  dplyr::distinct(rows, url, .keep_all = TRUE)
}

github_coletar_sementes_lista <- function(seeds, list_name, root, request_fn, budget) {
  # Known seed repositories use the official single-repository REST endpoint.
  # This makes list inclusion deterministic without searching or crawling all
  # entries in the global list. The response is visibility-checked before
  # cache, normalized through the same field allow-list, and contains no email.
  # (pt) Consultamos somente os repositórios brasileiros já selecionados,
  #      usando a API oficial e o mesmo cache, orçamento e allow-list da busca.
  candidates <- github_sementes_lista_brasileiras(seeds, list_name)
  rows <- lapply(seq_len(nrow(candidates)), function(i) {
    candidate <- candidates[i, , drop = FALSE]
    payload <- github_request(
      paste0("GET /repos/", candidate$full_name),
      list(), root, request_fn, budget, public_only = TRUE
    )
    item <- bind_github_items(list(list(payload)))
    item$solution_id <- candidate$solution_id
    item$seed_source <- candidate$seed_source
    item
  })
  dplyr::bind_rows(rows)
}

coletar_github <- function(seeds_path = "config/seeds.yml",
                           root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                           request_fn = NULL, search_terms, budget,
                           since = "2010-01-01", until = as.character(Sys.Date()),
                           include_curated_list = NULL) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  terms <- github_validar_termos(search_terms, seeds)
  curated_candidates <- if (is.null(include_curated_list)) {
    NULL
  } else {
    if (length(include_curated_list) != 1L || is.na(include_curated_list)) {
      stop("include_curated_list aceita um único nome de lista.", call. = FALSE)
    }
    github_sementes_lista_brasileiras(seeds, include_curated_list)
  }
  since_date <- as.Date(since)
  until_date <- as.Date(until)
  if (is.na(since_date) || is.na(until_date) || since_date > until_date) {
    stop("since/until precisam ser datas válidas em ordem crescente.", call. = FALSE)
  }
  required_github_requests <- length(terms) + nrow(curated_candidates %||% tibble::tibble())
  if (budget$tentativas_reservadas + required_github_requests > budget$max_tentativas) {
    stop("O orçamento não comporta as buscas e sementes curadas solicitadas.", call. = FALSE)
  }
  summaries <- vector("list", length(terms))
  searched <- purrr::map2_dfr(terms, seq_along(terms), function(term, i) {
    page <- github_search_window(term, format(since_date), format(until_date), root,
                                 request_fn, budget)
    summaries[[i]] <<- attr(page, "search_summary")
    page
  })
  curated <- if (is.null(include_curated_list)) {
    bind_github_items(list(list()))
  } else {
    github_coletar_sementes_lista(
      seeds, include_curated_list, root, request_fn, budget
    )
  }
  result <- dplyr::bind_rows(curated, searched) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  result <- aplicar_ids_sementes(result, seeds)
  attr(result, "radar_metadata") <- list(
    provider = "github",
    coverage = paste(
      "uma página por termo; resultados além da página não foram consultados;",
      "sementes explícitas da lista curada consultadas individualmente"
    ),
    searches = dplyr::bind_rows(summaries),
    curated_list = include_curated_list,
    budget = radar_resumo_orcamento(budget)
  )
  result
}

coletar_readme_github <- function(repositories,
                                  root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                                  request_fn = NULL, budget) {
  required <- c("full_name", "url")
  if (!all(required %in% names(repositories))) stop("repositories precisa de full_name e url.", call. = FALSE)
  radar_validar_orcamento(budget)
  if (nrow(repositories) > budget$max_documentos)
    stop(if (budget$max_documentos == 10L)
      "Selecione no máximo dez documentos antes do enriquecimento." else
      "Selecione documentos dentro do limite da rodada antes do enriquecimento.", call. = FALSE)
  radar_validate_cache_root(root)
  radar_reservar_documentos(budget, "github", repositories$full_name)
  details <- purrr::map(repositories$full_name, function(full_name) {
      if (is.na(full_name) || !grepl("/", full_name, fixed = TRUE))
        return(list(readme = NA_character_, content_hash = NA_character_))
      payload <- tryCatch(
        github_request(paste0("GET /repos/", full_name, "/readme"), list(), root,
                       request_fn, budget),
        error = function(error) {
          # Repositories without a README commonly return 404; this is a
          # missing document, not a reason to discard otherwise valid metadata.
          if (inherits(error, "http_error_404")) return(NULL)
          stop(error)
        }
      )
      if (is.null(payload) || is.null(payload$content))
        return(list(readme = NA_character_, content_hash = NA_character_))
      raw <- jsonlite::base64_dec(gsub("\\s+", "", payload$content))
      text <- rawToChar(raw)
      text <- enc2utf8(text)
      sha <- payload$sha %||% NA_character_
      list(readme = text, content_hash = if (is.na(sha)) NA_character_ else
             radar_content_hash("github", sha, text))
    })
  repositories$readme <- purrr::map_chr(details, "readme")
  repositories$content_hash <- purrr::map_chr(details, "content_hash")
  repositories
}
