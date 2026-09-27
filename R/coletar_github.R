# Public GitHub discovery / Descoberta pública no GitHub.
#
# (pt) Este módulo usa somente a API REST oficial. O modo exploratório exige
#      até dois termos explícitos das sementes, solicita uma página por termo,
#      não enumera contas e registra contagens e resultados incompletos. Cada
#      resposta bruta é cacheada antes da transformação e usa orçamento
#      compartilhado com HF e README; chamadas sem credenciais e sem
#      retentativa automática.
# (en) This module uses only the official REST API. Exploratory mode requires
#      up to two explicit seed terms, requests one page per term, never crawls
#      accounts, and records result counts and incomplete responses. Raw
#      responses are cached before transformation and share a request budget
#      with HF and README enrichment; requests are anonymous and automatic
#      retries are disabled.

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
      # Public endpoints work without credentials. Ignoring GITHUB_PAT ensures
      # direct README reads cannot expose private content to this collector.
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
    if (isTRUE(public_only)) github_validar_itens_publicos(payload)
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

github_validar_itens_publicos <- function(payload) {
  items <- payload$items %||% list()
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
      stars = integer(), updated_at = character(), topics = list(), readme = character()
    ))
  }
  # Explicit field allow-list prevents accidental ingestion of API fields such
  # as public email if GitHub changes its payload in the future.
  tibble::tibble(
    platform = "github",
    id = purrr::map_chr(items, ~ as.character(.x$id %||% NA_character_)),
    full_name = purrr::map_chr(items, ~ .x$full_name %||% NA_character_),
    name = purrr::map_chr(items, ~ .x$name %||% NA_character_),
    description = purrr::map_chr(items, ~ .x$description %||% NA_character_),
    url = purrr::map_chr(items, ~ .x$html_url %||% NA_character_),
    owner = purrr::map_chr(items, ~ .x$owner$login %||% NA_character_),
    language = purrr::map_chr(items, ~ .x$language %||% NA_character_),
    stars = purrr::map_int(items, ~ as.integer(.x$stargazers_count %||% 0L)),
    updated_at = purrr::map_chr(items, ~ .x$updated_at %||% NA_character_),
    topics = purrr::map(items, ~ unlist(.x$topics %||% character(), use.names = FALSE)),
    readme = NA_character_
  )
}

github_seed_terms <- function(seeds) {
  radar_seed_search_terms(seeds)
}

coletar_github <- function(seeds_path = "config/seeds.yml",
                           root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                           request_fn = NULL, search_terms, budget,
                           since = "2010-01-01", until = as.character(Sys.Date())) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  terms <- github_validar_termos(search_terms, seeds)
  since_date <- as.Date(since)
  until_date <- as.Date(until)
  if (is.na(since_date) || is.na(until_date) || since_date > until_date) {
    stop("since/until precisam ser datas válidas em ordem crescente.", call. = FALSE)
  }
  summaries <- vector("list", length(terms))
  searched <- purrr::map2_dfr(terms, seq_along(terms), function(term, i) {
    page <- github_search_window(term, format(since_date), format(until_date), root,
                                 request_fn, budget)
    summaries[[i]] <<- attr(page, "search_summary")
    page
  })
  result <- searched |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  result <- aplicar_ids_sementes(result, seeds)
  attr(result, "radar_metadata") <- list(
    provider = "github",
    coverage = "uma página por termo; resultados além da página não foram consultados",
    searches = dplyr::bind_rows(summaries),
    budget = radar_resumo_orcamento(budget)
  )
  result
}

coletar_readme_github <- function(repositories,
                                  root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                                  request_fn = NULL, budget) {
  required <- c("full_name", "url")
  if (!all(required %in% names(repositories))) stop("repositories precisa de full_name e url.", call. = FALSE)
  if (nrow(repositories) > 10L) stop("Selecione no máximo dez documentos antes do enriquecimento.", call. = FALSE)
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  radar_reservar_documentos(budget, "github", repositories$full_name)
  repositories |>
    dplyr::mutate(readme = purrr::map_chr(full_name, function(full_name) {
      if (is.na(full_name) || !grepl("/", full_name, fixed = TRUE)) return(NA_character_)
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
      if (is.null(payload) || is.null(payload$content)) return(NA_character_)
      raw <- jsonlite::base64_dec(gsub("\\s+", "", payload$content))
      text <- rawToChar(raw)
      enc2utf8(text)
    }))
}
