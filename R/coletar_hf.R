# Hugging Face Hub public API / API pública do Hugging Face Hub.
#
# (pt) A API do Hub oferece listagens públicas para modelos, datasets e Spaces.
#      Usamos os parâmetros oficiais de busca/autor e seguimos o cabeçalho Link
#      de paginação. O token é lido apenas de HF_TOKEN, nunca é incluído na chave
#      do cache nem no objeto bruto persistido. Campos são selecionados por
#      allow-list; e-mail e qualquer campo pessoal ficam fora do resultado.
# (en) The Hub API provides public listings for models, datasets, and Spaces.
#      We use its documented author/search parameters and follow Link pagination.
#      A token is read only from HF_TOKEN and is never part of the cache key or
#      persisted response. An explicit field allow-list excludes email and other
#      personal fields from the resulting corpus.

hf_api_page <- function(kind, query, root, request_fn = NULL) {
  key <- list(provider = "huggingface", kind = kind, query = query)
  radar_cached(key, function() {
    if (!is.null(request_fn)) return(request_fn(kind, query))
    request <- httr2::request(paste0("https://huggingface.co/api/", kind)) |>
      httr2::req_user_agent("bbsia-radar/0.1.0 (public research; contact: project repository)")
    request <- do.call(httr2::req_url_query, c(list(request), query)) |>
      httr2::req_retry(
        max_tries = 5, retry_on_failure = TRUE,
        is_transient = function(response) httr2::resp_status(response) %in% c(429, 500, 502, 503, 504)
      )
    token <- Sys.getenv("HF_TOKEN", unset = "")
    if (nzchar(token)) request <- httr2::req_headers(request, Authorization = paste("Bearer", token))
    response <- httr2::req_perform(request)
    httr2::resp_check_status(response)
    list(.radar_items = httr2::resp_body_json(response, simplifyVector = FALSE),
         .radar_next = hf_link_next(httr2::resp_header(response, "link")))
  }, root = root)
}

hf_link_next <- function(link) {
  if (is.null(link) || is.na(link) || !nzchar(link)) return(NULL)
  parts <- strsplit(link, ",\\s*", perl = TRUE)[[1]]
  next_part <- parts[grepl('rel="next"', parts, fixed = TRUE)]
  if (!length(next_part)) return(NULL)
  sub("^<([^>]+)>.*$", "\\1", next_part[[1]])
}

hf_collect_query <- function(kind, query, root, request_fn = NULL, max_pages = Inf) {
  collected <- list()
  next_url <- NULL
  page <- 1L
  repeat {
    payload <- if (is.null(next_url)) {
      hf_api_page(kind, query, root, request_fn)
    } else if (!is.null(request_fn)) {
      # Fixtures can expose a `next` element instead of an HTTP Link header.
      request_fn(kind, list(url = next_url, page = page))
    } else {
      key <- list(provider = "huggingface", url = next_url)
      radar_cached(key, function() {
        req <- httr2::request(next_url) |>
          httr2::req_user_agent("bbsia-radar/0.1.0 (public research)") |>
          httr2::req_retry(
            max_tries = 5, retry_on_failure = TRUE,
            is_transient = function(response) httr2::resp_status(response) %in% c(429, 500, 502, 503, 504)
          )
        token <- Sys.getenv("HF_TOKEN", unset = "")
        if (nzchar(token)) req <- httr2::req_headers(req, Authorization = paste("Bearer", token))
        resp <- httr2::req_perform(req)
        httr2::resp_check_status(resp)
        list(.radar_items = httr2::resp_body_json(resp, simplifyVector = FALSE),
             .radar_next = hf_link_next(httr2::resp_header(resp, "link")))
      }, root = root)
    }
    # Keep the Link header beside the cached JSON page. The wrapper survives
    # JSON serialization; plain injected fixture arrays remain supported too.
    if (is.list(payload) && !is.null(payload$.radar_items)) {
      items <- payload$.radar_items
      next_url <- payload$.radar_next
    } else if (is.list(payload) && !is.null(payload$items)) {
      # The `items` wrapper is convenient for deterministic fixtures; real
      # responses use the `.radar_items` wrapper above or a plain JSON array.
      items <- payload$items
      next_url <- payload[["next"]] %||% NULL
    } else {
      items <- payload
      next_url <- NULL
    }
    collected[[length(collected) + 1L]] <- items
    if (is.null(next_url) || page >= max_pages) break
    page <- page + 1L
  }
  unlist(collected, recursive = FALSE)
}

hf_seed_accounts <- function(seeds) {
  purrr::map_chr(seeds$contas$huggingface %||% list(), ~ .x$conta)
}

coletar_readme_hf <- function(repositories, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL) {
  required <- c("id", "kind")
  if (!all(required %in% names(repositories))) stop("repositories precisa de id e kind.", call. = FALSE)
  repositories |>
    dplyr::mutate(readme = purrr::map2_chr(id, kind, function(repo_id, kind) {
      if (is.na(repo_id) || !nzchar(repo_id)) return(NA_character_)
      key <- list(provider = "huggingface", file = "README.md", kind = kind, id = repo_id, revision = "main")
      radar_cached(key, function() {
        if (!is.null(request_fn)) return(request_fn(repo_id, kind, "README.md"))
        repo_prefix <- if (identical(kind, "models")) "" else paste0(kind, "/")
        url <- paste0("https://huggingface.co/", repo_prefix, repo_id, "/raw/main/README.md")
        req <- httr2::request(url) |>
          httr2::req_user_agent("bbsia-radar/0.1.0 (public research)") |>
          httr2::req_error(is_error = function(response) FALSE) |>
          httr2::req_retry(
            max_tries = 5, retry_on_failure = TRUE,
            is_transient = function(response) httr2::resp_status(response) %in% c(429, 500, 502, 503, 504)
          )
        token <- Sys.getenv("HF_TOKEN", unset = "")
        if (nzchar(token)) req <- httr2::req_headers(req, Authorization = paste("Bearer", token))
        response <- httr2::req_perform(req)
        if (httr2::resp_status(response) == 404L) return(NA_character_)
        httr2::resp_check_status(response)
        httr2::resp_body_string(response, encoding = "UTF-8")
      }, root = root)
    }))
}

hf_normalize_items <- function(items, kind) {
  if (!length(items)) return(tibble::tibble())
  # A direct lookup (`/api/models/{id}`) returns one object, while list/search
  # endpoints return an array of objects. Normalize both wire shapes here.
  if (!is.null(items$id) || !is.null(items$repo_id)) items <- list(items)
  purrr::map_dfr(items, function(item) {
    model_id <- item$id %||% item$repo_id %||% NA_character_
    owner <- if (!is.na(model_id) && grepl("/", model_id, fixed = TRUE)) sub("/.*$", "", model_id) else NA_character_
    tibble::tibble(
      platform = "huggingface", kind = kind,
      id = as.character(model_id), full_name = as.character(model_id),
      name = ifelse(is.na(model_id), NA_character_, sub("^.*/", "", model_id)),
      description = item$cardData$description %||% item$description %||% NA_character_,
      url = ifelse(is.na(model_id), NA_character_, paste0(
        "https://huggingface.co/", if (identical(kind, "models")) "" else paste0(kind, "/"), model_id
      )),
      owner = owner,
      language = NA_character_, stars = as.integer(item$likes %||% 0L),
      updated_at = item$lastModified %||% NA_character_,
      topics = list(unlist(item$tags %||% character(), use.names = FALSE)),
      readme = NA_character_
    )
  })
}

coletar_hf <- function(seeds_path = "config/seeds.yml", root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""), request_fn = NULL, max_pages = Inf) {
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  accounts <- hf_seed_accounts(seeds)
  known <- purrr::map_chr(seeds$gabarito %||% list(), function(solution) {
    urls <- purrr::map_chr(solution$artefatos %||% list(), ~ .x$url)
    hf <- urls[grepl("huggingface.co/", urls, fixed = TRUE)]
    if (length(hf)) sub("^https://huggingface.co/", "", hf[[1]]) else NA_character_
  })
  known <- stats::na.omit(known)
  kinds <- c("models", "datasets", "spaces")
  results <- list()
  for (kind in kinds) {
    for (account in accounts) {
      items <- hf_collect_query(kind, list(author = account, limit = 100, full = "true"), root, request_fn, max_pages)
      results[[length(results) + 1L]] <- hf_normalize_items(items, kind)
    }
    # Known-positive IDs are requested explicitly too: this makes recall
    # fixtures visible even if their owner is no longer in the curated list.
    matching <- known[grepl("/", known, fixed = TRUE)]
    for (repo_id in matching) {
      if (kind == "models") {
        item <- hf_api_page(paste0("models/", repo_id), list(), root, request_fn)
        body <- if (!is.null(item$.radar_items)) item$.radar_items else item
        results[[length(results) + 1L]] <- hf_normalize_items(body, kind)
      }
    }
  }
  result <- dplyr::bind_rows(results) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  aplicar_ids_sementes(result, seeds)
}
