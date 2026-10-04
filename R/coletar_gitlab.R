# GitLab.com public project discovery / Descoberta de projetos públicos no GitLab.com.
#
# (pt) Este módulo usa somente a API REST oficial v4 e pedidos anônimos. A
#      busca é limitada às sementes aprovadas e a uma página por termo; a API
#      pesquisa nome, caminho e descrição, não o conteúdo do código. Uma
#      visibilidade ausente ou diferente de `public` é rejeitada antes do
#      cache. O README é opcional e só é baixado após HEAD confirmar o tamanho.
# (en) This module uses only the official REST v4 API and anonymous requests.
#      Search is limited to approved seeds and one page per term; the API
#      searches project name, path, and description, not source-code contents.
#      Missing or non-public visibility is rejected before caching. README
#      enrichment is optional and follows a HEAD size check.

gitlab_api_url <- function(path) {
  paste0("https://gitlab.com/api/v4", if (startsWith(path, "/")) path else paste0("/", path))
}

gitlab_http_request <- function(method, path, query = list()) {
  method <- toupper(method)
  request <- httr2::request(gitlab_api_url(path)) |>
    httr2::req_method(method) |>
    httr2::req_user_agent("bbsia-radar/0.1.0 (public research; see repository)") |>
    httr2::req_options(followlocation = FALSE, maxredirs = 0) |>
    httr2::req_error(is_error = function(response) FALSE) |>
    httr2::req_timeout(30)
  if (identical(method, "GET") && grepl("/repository/files/README\\.md$", path)) {
    # (pt) O limite abrange o JSON/Base64 inteiro e interrompe uma resposta
    #      maior antes que ela seja totalmente mantida em memória.
    # (en) Bound the complete JSON/Base64 response so an unexpectedly large
    #      payload is stopped before being fully retained in memory.
    request <- request |> httr2::req_options(maxfilesize_large = 512L * 1024L)
  }
  if (length(query)) request <- do.call(httr2::req_url_query, c(list(request), query))

  response <- httr2::req_perform(request)
  status <- httr2::resp_status(response)
  headers <- as.list(httr2::resp_headers(response))
  body <- NULL
  if (method != "HEAD" && !is.na(status) && status >= 200L && status < 300L) {
    body <- httr2::resp_body_json(response, simplifyVector = FALSE)
  } else if (method != "HEAD" && !is.na(status) && status >= 300L) {
    body <- tryCatch(
      httr2::resp_body_json(response, simplifyVector = FALSE),
      error = function(error) httr2::resp_body_string(response, encoding = "UTF-8")
    )
  }
  list(status = as.integer(status), headers = headers, body = body)
}

gitlab_normalize_response <- function(response) {
  if (is.list(response) && !is.null(response$.radar_http_status)) {
    return(list(
      .radar_http_status = as.integer(response$.radar_http_status),
      .radar_headers = gitlab_safe_headers(response$.radar_headers %||% list()),
      .radar_body = response$.radar_http_body %||% NULL
    ))
  }
  if (!is.list(response) || length(response$status) != 1L || is.na(response$status)) {
    stop("A resposta GitLab precisa informar um status HTTP único.", call. = FALSE)
  }
  list(
    .radar_http_status = as.integer(response$status),
    .radar_headers = gitlab_safe_headers(response$headers %||% list()),
    .radar_body = response$body %||% NULL
  )
}

gitlab_safe_headers <- function(headers) {
  allowed <- c(
    "x-next-page", "x-total", "x-total-pages", "link", "x-gitlab-size",
    "x-gitlab-commit-id", "x-gitlab-blob-id", "retry-after"
  )
  values <- unlist(headers, recursive = TRUE, use.names = TRUE)
  if (!length(values) || is.null(names(values))) return(list())
  keep <- tolower(names(values)) %in% allowed
  as.list(stats::setNames(as.character(values[keep]), tolower(names(values[keep]))))
}

gitlab_retry_after_time <- function(headers, cached_at, status) {
  value <- gitlab_header(headers, "retry-after")
  fallback <- if (status >= 500L) 300 else 3600
  if (is.na(value) || !nzchar(value)) return(cached_at + fallback)
  seconds <- suppressWarnings(as.numeric(value))
  if (length(seconds) == 1L && is.finite(seconds) && seconds >= 0) {
    return(cached_at + seconds)
  }
  retry_at <- suppressWarnings(as.POSIXct(
    value, format = "%a, %d %b %Y %H:%M:%S GMT", tz = "GMT"
  ))
  if (is.na(retry_at)) return(cached_at + fallback)
  retry_at
}

gitlab_cache_error_expired <- function(cached, cached_at, now = Sys.time()) {
  status <- suppressWarnings(as.integer(cached$.radar_http_status %||% NA_integer_))
  retryable <- identical(status, 403L) || identical(status, 408L) ||
    identical(status, 429L) || (!is.na(status) && status >= 500L)
  if (!retryable) return(FALSE)
  if (length(cached_at) != 1L || is.na(cached_at)) return(TRUE)
  expires_at <- gitlab_retry_after_time(
    cached$.radar_headers %||% list(), cached_at, status
  )
  as.numeric(now) >= as.numeric(expires_at)
}

gitlab_send_request <- function(method, path, query, request_fn = NULL) {
  response <- if (is.null(request_fn)) {
    gitlab_http_request(method, path, query)
  } else {
    request_fn(method, path, query)
  }
  gitlab_normalize_response(response)
}

gitlab_items <- function(body) {
  if (is.null(body) || !length(body)) return(list())
  items <- body$items %||% body
  if (is.list(items) && (!is.null(items$id) || !is.null(items$web_url))) items <- list(items)
  if (!is.list(items)) stop("A resposta GitLab de projetos não é uma lista.", call. = FALSE)
  items
}

gitlab_validar_projetos_publicos <- function(body) {
  items <- gitlab_items(body)
  if (!length(items)) return(invisible(body))
  confirmed_public <- purrr::map_lgl(items, function(project) {
    is.character(project$visibility) && length(project$visibility) == 1L &&
      identical(project$visibility, "public")
  })
  if (any(!confirmed_public)) {
    stop("GitLab rejeitou projeto sem visibility=public; cache bloqueado.",
         call. = FALSE)
  }
  invisible(body)
}

gitlab_request <- function(method, path, query = list(), root,
                           request_fn = NULL, budget, reserved_attempts = 1L,
                           require_public_projects = FALSE, refresh = FALSE,
                           validate_response = NULL) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  method <- toupper(method)
  key <- list(provider = "gitlab", method = method, path = path, query = query)
  payload <- radar_cached(key, function() {
    radar_reservar_requisicao(budget, "gitlab", paste(method, path), reserved_attempts)
    response <- gitlab_send_request(method, path, query, request_fn)
    status <- response$.radar_http_status
    radar_registrar_status(budget, "gitlab", status, paste(method, path))
    if (is.na(status) || status < 200L || status >= 300L) return(response)
    if (isTRUE(require_public_projects)) gitlab_validar_projetos_publicos(response$.radar_body)
    if (is.function(validate_response)) response <- validate_response(response)
    response
  }, root = root, refresh = refresh, refresh_if = gitlab_cache_error_expired)
  payload
}

gitlab_header <- function(headers, name) {
  if (is.null(headers) || !length(headers)) return(NA_character_)
  values <- unlist(headers, recursive = TRUE, use.names = TRUE)
  if (!length(values) || is.null(names(values))) return(NA_character_)
  position <- match(tolower(name), tolower(names(values)))
  if (is.na(position)) return(NA_character_)
  as.character(values[[position]])
}

gitlab_next_page <- function(headers) {
  next_page <- gitlab_header(headers, "x-next-page")
  if (!is.na(next_page) && nzchar(next_page)) return(next_page)
  link <- gitlab_header(headers, "link")
  if (is.na(link) || !nzchar(link)) return(NA_character_)
  parts <- strsplit(link, ",\\s*", perl = TRUE)[[1]]
  next_part <- parts[grepl('rel="next"', parts, fixed = TRUE)]
  if (!length(next_part)) return(NA_character_)
  sub("^<[^>]*[?&]page=([^&>]+)[^>]*>.*$", "\\1", next_part[[1]])
}

gitlab_numero_header <- function(headers, name) {
  value <- suppressWarnings(as.integer(gitlab_header(headers, name)))
  if (!length(value) || is.na(value)) return(NA_integer_)
  value
}

gitlab_search_page <- function(term, root, request_fn = NULL, budget) {
  query <- list(
    search = term,
    visibility = "public",
    simple = TRUE,
    page = 1L,
    per_page = 100L,
    order_by = "created_at",
    sort = "desc"
  )
  response <- gitlab_request(
    "GET", "/projects", query, root, request_fn, budget,
    require_public_projects = TRUE
  )
  status <- response$.radar_http_status
  if (is.na(status) || status < 200L || status >= 300L) {
    radar_verificar_status_http(status, "GitLab", "/projects")
  }
  items <- gitlab_items(response$.radar_body)
  next_page <- gitlab_next_page(response$.radar_headers)
  total <- gitlab_numero_header(response$.radar_headers, "x-total")
  total_pages <- gitlab_numero_header(response$.radar_headers, "x-total-pages")
  summary <- tibble::tibble(
    term = term,
    page = 1L,
    per_page = 100L,
    order_by = "created_at",
    sort = "desc",
    total_count = total,
    total_pages = total_pages,
    next_page = next_page,
    has_next_page = !is.na(next_page) && nzchar(next_page),
    returned = length(items),
    truncated = (!is.na(total) && total > length(items)) ||
      (!is.na(total_pages) && total_pages > 1L) ||
      (!is.na(next_page) && nzchar(next_page))
  )
  result <- gitlab_normalize_items(items)
  attr(result, "search_summary") <- summary
  result
}

gitlab_seed_terms <- function(seeds) {
  radar_seed_search_terms(seeds)
}

gitlab_validar_termos <- function(search_terms, seeds) {
  if (is.null(search_terms) || !length(search_terms) || anyNA(search_terms) ||
      any(!nzchar(trimws(search_terms)))) {
    stop("Informe explicitamente um ou dois termos de busca derivados das sementes.", call. = FALSE)
  }
  if (length(search_terms) > 2L || anyDuplicated(search_terms)) {
    stop("A busca exploratória aceita no máximo dois termos distintos.", call. = FALSE)
  }
  allowed <- gitlab_seed_terms(seeds)
  if (!all(search_terms %in% allowed)) {
    stop("Cada termo precisa corresponder a um nome ou artefato já presente em config/seeds.yml.",
         call. = FALSE)
  }
  unname(search_terms)
}

gitlab_normalize_items <- function(items) {
  if (!length(items)) {
    return(tibble::tibble(
      platform = character(), id = character(), full_name = character(), name = character(),
      description = character(), url = character(), owner = character(), language = character(),
      stars = integer(), updated_at = character(), updated_at_semantics = character(),
      topics = list(), readme = character(), solution_id = character(),
      created_at = character(), archived = logical()
    ))
  }
  if (!is.null(items$id) || !is.null(items$web_url)) items <- list(items)
  projects <- purrr::map_dfr(items, function(project) {
    id <- project$id %||% NA_character_
    name <- project$name %||% NA_character_
    full_name <- project$path_with_namespace %||% project$path %||% name
    url <- project$web_url %||% NA_character_
    namespace <- project$namespace %||% list()
    owner <- namespace$full_path %||% namespace$path %||% NA_character_
    if ((is.null(owner) || length(owner) == 0L || is.na(owner)) &&
        !is.na(full_name) && grepl("/", full_name, fixed = TRUE)) {
      owner <- sub("/[^/]+$", "", full_name)
    }
    tibble::tibble(
      platform = "gitlab",
      id = if (is.numeric(id)) format(id, scientific = FALSE, trim = TRUE) else as.character(id),
      full_name = as.character(full_name),
      name = as.character(name),
      description = as.character(project$description %||% NA_character_),
      url = as.character(url),
      owner = as.character(owner),
      language = NA_character_,
      stars = suppressWarnings(as.integer(project$star_count %||% NA_integer_)),
      updated_at = as.character(project$last_activity_at %||% NA_character_),
      updated_at_semantics = "project_activity_at",
      topics = list(unlist(project$topics %||% project$tag_list %||% character(), use.names = FALSE)),
      readme = NA_character_,
      solution_id = as.character(url),
      created_at = as.character(project$created_at %||% NA_character_),
      archived = isTRUE(project$archived)
    )
  })
  projects
}

coletar_gitlab <- function(seeds_path = "config/seeds.yml",
                           root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                           request_fn = NULL, search_terms, budget) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  terms <- gitlab_validar_termos(search_terms, seeds)
  summaries <- vector("list", length(terms))
  searched <- purrr::map2_dfr(terms, seq_along(terms), function(term, index) {
    page <- gitlab_search_page(term, root, request_fn, budget)
    summaries[[index]] <<- attr(page, "search_summary")
    page
  })
  result <- searched |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE) |>
    aplicar_ids_sementes(seeds)
  attr(result, "radar_metadata") <- list(
    provider = "gitlab",
    instance = "https://gitlab.com",
    searches = dplyr::bind_rows(summaries),
    coverage = "uma página por termo; nome, caminho e descrição; não cobre o conteúdo do código",
    budget = radar_resumo_orcamento(budget)
  )
  result
}

gitlab_readme_path <- function(project_id) {
  project_id <- utils::URLencode(as.character(project_id), reserved = TRUE)
  paste0("/projects/", project_id, "/repository/files/README.md")
}

gitlab_readme_payload <- function(project_id, root, request_fn, budget, max_bytes) {
  path <- gitlab_readme_path(project_id)
  head_query <- list(ref = "HEAD")
  head <- gitlab_request(
    "HEAD", path, head_query, root, request_fn, budget,
    refresh = TRUE
  )
  head_status <- head$.radar_http_status
  if (is.na(head_status) || head_status < 200L || head_status >= 300L) {
    return(list(.radar_http_status = head_status, .radar_http_body = head$.radar_body))
  }
  size <- suppressWarnings(as.numeric(gitlab_header(head$.radar_headers, "x-gitlab-size")))
  if (length(size) != 1L || is.na(size) || size < 0) {
    return(list(.radar_skip = "size_header_missing", .radar_size = NA_real_))
  }
  if (size > max_bytes) {
    return(list(.radar_skip = "over_size_limit", .radar_size = size))
  }
  commit_id <- gitlab_header(head$.radar_headers, "x-gitlab-commit-id")
  blob_id <- gitlab_header(head$.radar_headers, "x-gitlab-blob-id")
  if (is.na(commit_id) || !nzchar(commit_id) || is.na(blob_id) || !nzchar(blob_id)) {
    return(list(.radar_skip = "revision_metadata_missing", .radar_size = size))
  }

  # (pt) O HEAD e atualizado em cada rodada. O GET aponta para o commit exato
  #      que o HEAD confirmou; o cache do conteudo e identificado pelo commit.
  # (en) HEAD is refreshed for every run. GET pins the exact commit confirmed
  #      by HEAD, and its content cache is keyed by that immutable revision.
  get_query <- list(ref = commit_id)
  validate_readme <- function(response) {
    body <- response$.radar_body
    get_size <- suppressWarnings(as.numeric(body$size %||% NA_real_))
    content <- body$content %||% NULL
    if (length(get_size) != 1L || is.na(get_size) || get_size != size || get_size > max_bytes) {
      response$.radar_body <- NULL
      response$.radar_skip <- "size_changed_or_missing"
      return(response)
    }
    if (!identical(body$encoding, "base64") || !is.character(content) || length(content) != 1L) {
      response$.radar_body <- NULL
      response$.radar_skip <- "unsupported_file_encoding"
      return(response)
    }
    compact <- gsub("\\s+", "", content)
    encoded_limit <- 4 * ceiling(max_bytes / 3)
    if (nchar(compact, type = "bytes") > encoded_limit) {
      response$.radar_body <- NULL
      response$.radar_skip <- "over_size_limit_after_get"
      return(response)
    }
    decoded <- tryCatch(jsonlite::base64_dec(compact), error = function(error) NULL)
    if (is.null(decoded)) {
      response$.radar_body <- NULL
      response$.radar_skip <- "invalid_base64"
      return(response)
    }
    if (length(decoded) > max_bytes) {
      response$.radar_body <- NULL
      response$.radar_skip <- "over_size_limit_after_get"
      return(response)
    }
    if (!identical(as.character(body$commit_id %||% ""), commit_id) ||
        !identical(as.character(body$blob_id %||% ""), blob_id)) {
      response$.radar_body <- NULL
      response$.radar_skip <- "revision_changed_during_read"
      return(response)
    }
    response
  }
  fetched <- gitlab_request(
    "GET", path, get_query, root, request_fn, budget,
    validate_response = validate_readme
  )
  status <- fetched$.radar_http_status %||% NA_integer_
  if (!is.na(status) && (status < 200L || status >= 300L)) {
    return(list(.radar_http_status = status, .radar_http_body = fetched$.radar_body))
  }
  if (!is.null(fetched$.radar_skip)) {
    return(list(.radar_skip = fetched$.radar_skip, .radar_size = size))
  }
  body <- fetched$.radar_body
  list(
    .radar_size = size,
    encoding = body$encoding,
    content = body$content,
    .radar_last_commit_id = body$last_commit_id %||% NA_character_,
    .radar_file_path = body$file_path %||% "README.md"
  )
}

coletar_readme_gitlab <- function(repositories,
                                  root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                                  request_fn = NULL, budget,
                                  max_bytes = 256L * 1024L) {
  required <- c("id", "url")
  if (!all(required %in% names(repositories))) {
    stop("repositories precisa de id e url.", call. = FALSE)
  }
  if (nrow(repositories) > 10L) stop("Selecione no máximo dez documentos antes do enriquecimento.", call. = FALSE)
  max_bytes <- suppressWarnings(as.integer(max_bytes))
  if (length(max_bytes) != 1L || is.na(max_bytes) || max_bytes < 1L ||
      max_bytes > 256L * 1024L) {
    stop("max_bytes precisa estar entre 1 e 256 KiB.", call. = FALSE)
  }
  if (anyNA(repositories$id) || any(!nzchar(as.character(repositories$id)))) {
    stop("Cada projeto GitLab precisa de id numérico ou textual da API.", call. = FALSE)
  }
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  radar_reservar_documentos(budget, "gitlab", repositories$id)
  details <- purrr::map(as.character(repositories$id), function(project_id) {
    payload <- gitlab_readme_payload(project_id, root, request_fn, budget, max_bytes)
    status <- payload$.radar_http_status %||% NA_integer_
    if (!is.na(status)) {
      if (identical(as.integer(status), 404L)) return(list(readme = NA_character_, readme_status = "missing", content_hash = NA_character_))
      if (identical(as.integer(status), 451L)) return(list(readme = NA_character_, readme_status = "bloqueio_legal", content_hash = NA_character_))
      radar_verificar_status_http(status, "GitLab", "README.md")
    }
    skip <- payload$.radar_skip %||% NULL
    if (!is.null(skip)) return(list(readme = NA_character_, readme_status = as.character(skip), content_hash = NA_character_))
    raw <- jsonlite::base64_dec(gsub("\\s+", "", payload$content))
    if (length(raw) > max_bytes) {
      return(list(readme = NA_character_, readme_status = "over_size_limit_after_get", content_hash = NA_character_))
    }
    text <- if (length(raw)) rawToChar(raw) else ""
    if (length(raw)) Encoding(text) <- "UTF-8"
    last_commit <- payload$.radar_last_commit_id
    list(readme = text, readme_status = "read",
         content_hash = if (is.na(last_commit) || !nzchar(last_commit))
           NA_character_ else radar_content_hash("gitlab", last_commit, text))
  })
  repositories$readme <- purrr::map_chr(details, "readme")
  repositories$readme_status <- purrr::map_chr(details, "readme_status")
  repositories$content_hash <- purrr::map_chr(details, "content_hash")
  repositories
}
