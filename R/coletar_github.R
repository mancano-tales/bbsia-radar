# Public GitHub discovery / Descoberta pública no GitHub.
#
# (pt) Este módulo usa somente a API oficial REST. Ele procura termos de
#      `listas` e `gabarito` e enumera as contas explicitamente curadas em
#      `config/seeds.yml`; não acessa dados de perfil nem solicita e-mail.
#      Cada página bruta é cacheada antes da transformação. Consultas de busca
#      são subdivididas por data quando a API informa mais de mil resultados.
# (en) This module uses only the official REST API. It searches terms derived
#      from curated lists and known positives, and enumerates explicitly curated
#      accounts; it never calls profile endpoints or requests email. Every raw
#      page is cached before transformation. Search windows are recursively
#      split when GitHub's 1,000-result search cap would hide results.

github_request <- function(path, query = list(), root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL) {
  key <- list(provider = "github", path = path, query = query)
  radar_cached(key, function() {
    if (!is.null(request_fn)) return(request_fn(path, query))
    # gh uses GITHUB_PAT from the process environment; credentials are never
    # copied into arguments, logs, files tracked by git, or cached responses.
    gh::gh(path, .params = query, .send_headers = c("User-Agent" = "bbsia-radar/0.1.0"),
           .max_wait = 600, .max_rate = 0.8)
  }, root = root)
}

github_search_window <- function(term, start_date, end_date, root, request_fn = NULL) {
  q <- paste(term, paste0("created:", start_date, "..", end_date))
  first <- github_request("GET /search/repositories", list(q = q, per_page = 100, page = 1), root, request_fn)
  total <- as.integer(first$total_count %||% length(first$items))
  if (total > 1000L) {
    first_day <- as.Date(start_date)
    last_day <- as.Date(end_date)
    if (first_day >= last_day) stop("GitHub Search continua acima de 1.000 resultados no menor intervalo.", call. = FALSE)
    mid <- first_day + floor(as.numeric(last_day - first_day) / 2)
    left <- github_search_window(term, format(first_day), format(mid), root, request_fn)
    right <- github_search_window(term, format(mid + 1), format(last_day), root, request_fn)
    return(dplyr::bind_rows(left, right))
  }
  pages <- list(first$items %||% list())
  if (total > 100L) {
    for (page in seq.int(2L, ceiling(total / 100))) {
      result <- github_request("GET /search/repositories", list(q = q, per_page = 100, page = page), root, request_fn)
      pages[[length(pages) + 1L]] <- result$items %||% list()
    }
  }
  bind_github_items(pages)
}

bind_github_items <- function(pages) {
  items <- unlist(pages, recursive = FALSE)
  if (!length(items)) return(tibble::tibble())
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
  list_names <- purrr::map_chr(seeds$listas %||% list(), ~ .x$nome)
  repo_names <- purrr::map_chr(seeds$gabarito %||% list(), ~ sub(".*/", "", .x$artefatos[[1]]$url))
  unique(c(list_names, repo_names))
}

github_seed_accounts <- function(seeds, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL) {
  accounts <- seeds$contas$github %||% list()
  purrr::map_dfr(accounts, function(account) {
    route <- if (identical(account$tipo, "organizacao")) "orgs" else "users"
    page <- 1L
    pages <- list()
    repeat {
      payload <- github_request(paste0("GET /", route, "/", account$conta, "/repos"),
                                list(per_page = 100, page = page, sort = "updated"), root, request_fn)
      pages[[length(pages) + 1L]] <- payload
      if (length(payload) < 100L) break
      page <- page + 1L
    }
    bind_github_items(list(unlist(pages, recursive = FALSE)))
  })
}

coletar_github <- function(seeds_path = "config/seeds.yml", root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL, since = "2010-01-01", until = as.character(Sys.Date())) {
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  terms <- github_seed_terms(seeds)
  searched <- purrr::map_dfr(terms, function(term) {
    github_search_window(term, since, until, root = root, request_fn = request_fn)
  })
  accounts <- github_seed_accounts(seeds, root, request_fn)
  result <- dplyr::bind_rows(searched, accounts) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  aplicar_ids_sementes(result, seeds)
}

coletar_readme_github <- function(repositories, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL) {
  required <- c("full_name", "url")
  if (!all(required %in% names(repositories))) stop("repositories precisa de full_name e url.", call. = FALSE)
  repositories |>
    dplyr::mutate(readme = purrr::map_chr(full_name, function(full_name) {
      if (is.na(full_name) || !grepl("/", full_name, fixed = TRUE)) return(NA_character_)
      payload <- tryCatch(
        github_request(paste0("GET /repos/", full_name, "/readme"), list(), root, request_fn),
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
