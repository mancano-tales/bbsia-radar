# Hugging Face Hub public API / API pública do Hugging Face Hub.
#
# (pt) O modo exploratório consulta uma única página de `models` para uma conta
#      explicitamente selecionada das sementes. Não segue `Link`, não consulta
#      positivos conhecidos, não envia HF_TOKEN e não repete requisições.
#      Campos de saída usam allow-list sem e-mail ou dados pessoais.
# (en) Exploratory mode requests one `models` page for one explicitly selected
#      seed account. It does not follow `Link`, query known positives, or retry.
#      It never sends HF_TOKEN; output fields are allow-listed and exclude
#      email and other personal data.

hf_api_page <- function(kind, query, root, request_fn = NULL, budget, reserved_attempts = 1L) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  key <- list(provider = "huggingface", kind = kind, query = query)
  payload <- radar_cached(key, function() {
    radar_reservar_requisicao(budget, "huggingface", kind, reserved_attempts)
    if (!is.null(request_fn)) {
      payload <- request_fn(kind, query)
    } else {
      request <- httr2::request(paste0("https://huggingface.co/api/", kind)) |>
        httr2::req_user_agent("bbsia-radar/0.1.0 (public research; see repository)") |>
        httr2::req_options(followlocation = FALSE) |>
        httr2::req_error(is_error = function(response) FALSE)
      request <- do.call(httr2::req_url_query, c(list(request), query)) |>
        httr2::req_timeout(30)
      # These queries discover public seed models only, so never attach
      # HF_TOKEN; authenticated listing could include private models.
      response <- httr2::req_perform(request)
      status <- httr2::resp_status(response)
      if (is.na(status) || status < 200L || status >= 300L) {
        body <- tryCatch(httr2::resp_body_json(response, simplifyVector = FALSE),
                         error = function(error) httr2::resp_body_string(response))
        payload <- list(.radar_http_status = status, .radar_http_body = body)
      } else {
        payload <- list(.radar_items = httr2::resp_body_json(response, simplifyVector = FALSE),
                        .radar_next = hf_link_next(httr2::resp_header(response, "link")))
      }
    }
    radar_registrar_status(budget, "huggingface", radar_status_resposta(payload), kind)
    hf_validar_itens_publicos(payload)
    payload
  }, root = root)
  if (is.list(payload) && !is.null(payload$.radar_http_status)) {
    radar_verificar_status_http(payload$.radar_http_status, "Hugging Face", kind)
  }
  payload
}

hf_link_next <- function(link) {
  if (is.null(link) || is.na(link) || !nzchar(link)) return(NULL)
  parts <- strsplit(link, ",\\s*", perl = TRUE)[[1]]
  next_part <- parts[grepl('rel="next"', parts, fixed = TRUE)]
  if (!length(next_part)) return(NULL)
  sub("^<([^>]+)>.*$", "\\1", next_part[[1]])
}

hf_collect_query <- function(kind, query, root, request_fn = NULL, max_pages = 1L, budget) {
  if (length(max_pages) != 1L || is.na(max_pages) || max_pages != 1L) {
    stop("A amostra exploratória aceita exatamente uma página do Hugging Face.", call. = FALSE)
  }
  payload <- hf_api_page(kind, query, root, request_fn, budget)
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
  result <- unlist(list(items), recursive = FALSE)
  attr(result, "pagination_summary") <- list(pages_requested = 1L, has_next_page = !is.null(next_url))
  result
}

hf_validar_itens_publicos <- function(payload) {
  # Error wrappers carry an HTTP status/body rather than model records.
  # Preserve the original status so 403/429 are reported and cached correctly.
  if (is.list(payload) && !is.null(payload$.radar_http_status)) return(invisible(payload))
  items <- payload$.radar_items %||% payload$items %||% payload
  if (is.list(items) && (!is.null(items$id) || !is.null(items$repo_id))) items <- list(items)
  if (is.list(items) && length(items) &&
      any(purrr::map_lgl(items, ~ isTRUE(.x$private)))) {
    stop("A listagem do Hugging Face retornou um modelo privado; a resposta não será cacheada.",
         call. = FALSE)
  }
  invisible(payload)
}

hf_seed_accounts <- function(seeds) {
  purrr::map_chr(seeds$contas$huggingface %||% list(), ~ .x$conta)
}

coletar_readme_hf <- function(repositories,
                              root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                              request_fn = NULL, budget) {
  required <- c("id", "kind", "sha")
  if (!all(required %in% names(repositories))) stop("repositories precisa de id, kind e sha.", call. = FALSE)
  if (nrow(repositories) > budget$max_documentos)
    stop(if (budget$max_documentos == 10L)
      "Selecione no máximo dez documentos antes do enriquecimento." else
      "Selecione documentos dentro do limite da rodada antes do enriquecimento.", call. = FALSE)
  if (anyNA(repositories$kind) || any(repositories$kind != "models")) {
    stop("O modo exploratório só enriquece model cards de modelos.", call. = FALSE)
  }
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  radar_reservar_documentos(budget, "huggingface", repositories$id)
  details <- purrr::pmap(list(repositories$id, repositories$kind, repositories$sha),
    function(repo_id, kind, sha) {
      if (is.na(repo_id) || !nzchar(repo_id) || is.na(sha) || !nzchar(sha))
        return(list(readme = NA_character_, content_hash = NA_character_,
                    readme_status = "sem_sha"))
      if (!grepl("^[0-9a-f]{40}([0-9a-f]{24})?$", sha))
        stop("Hugging Face exige SHA imutável do commit.", call. = FALSE)
      key <- list(provider = "huggingface", file = "README.md", kind = kind, id = repo_id, revision = sha)
      payload <- radar_cached(key, function() {
        radar_reservar_requisicao(budget, "huggingface", paste0(kind, "/", repo_id, "/README.md"), 2L)
        if (!is.null(request_fn)) {
          response <- request_fn(repo_id, kind, "README.md")
          radar_registrar_status(budget, "huggingface", radar_status_resposta(response), "README.md")
          return(response)
        }
        repo_prefix <- if (identical(kind, "models")) "" else paste0(kind, "/")
        url <- paste0("https://huggingface.co/", repo_prefix, repo_id, "/raw/", sha, "/README.md")
        req <- httr2::request(url) |>
          httr2::req_user_agent("bbsia-radar/0.1.0 (public research)") |>
          httr2::req_error(is_error = function(response) FALSE) |>
          httr2::req_options(maxredirs = 1) |>
          httr2::req_timeout(30)
        # Model cards are public in this run; do not send HF_TOKEN across a
        # redirect to the content CDN.
        response <- httr2::req_perform(req)
        status <- httr2::resp_status(response)
        radar_registrar_status(budget, "huggingface", status, "README.md")
        if (is.na(status) || status < 200L || status >= 300L) {
          return(list(.radar_http_status = status,
                      .radar_http_body = httr2::resp_body_string(response, encoding = "UTF-8")))
        }
        httr2::resp_body_string(response, encoding = "UTF-8")
      }, root = root)
      if (is.list(payload) && !is.null(payload$.radar_http_status)) {
        # (pt) 404 = sem card; 401/403 = acesso negado sem login (o radar não
        #      envia HF_TOKEN): em geral modelo de acesso controlado (gated),
        #      mas o código HTTP sozinho não prova o motivo; 451 = bloqueio legal. São
        #      ausências deste item. 429 (limite) e outros erros param a rodada.
        # (en) Gated or missing cards are item-level absences.
        status_hf <- as.integer(payload$.radar_http_status)
        motivo <- c(`404` = "missing", `401` = "acesso_negado", `403` = "acesso_negado", `451` = "bloqueio_legal")
        if (as.character(status_hf) %in% names(motivo))
          return(list(readme = NA_character_, content_hash = NA_character_,
                      readme_status = unname(motivo[as.character(status_hf)])))
        radar_verificar_status_http(payload$.radar_http_status, "Hugging Face", "README.md")
      }
      list(readme = payload, content_hash = radar_content_hash("huggingface", sha, payload),
           readme_status = "read")
    })
  repositories$readme <- purrr::map_chr(details, "readme")
  repositories$content_hash <- purrr::map_chr(details, "content_hash")
  repositories$readme_status <- purrr::map_chr(details, "readme_status")
  repositories
}

hf_normalize_items <- function(items, kind) {
  if (!length(items)) {
    return(tibble::tibble(
      platform = character(), kind = character(), id = character(), full_name = character(),
      name = character(), description = character(), url = character(), owner = character(),
      language = character(), stars = integer(), updated_at = character(), topics = list(),
      readme = character(), sha = character(), downloads = integer(),
      created_at = character(), license = character(), pipeline_tag = character()
    ))
  }
  # A direct lookup (`/api/models/{id}`) returns one object, while list/search
  # endpoints return an array of objects. Normalize both wire shapes here.
  if (!is.null(items$id) || !is.null(items$repo_id)) items <- list(items)
  purrr::map_dfr(items, function(item) {
    model_id <- item$id %||% item$repo_id %||% NA_character_
    owner <- if (!is.na(model_id) && grepl("/", model_id, fixed = TRUE)) sub("/.*$", "", model_id) else NA_character_
    tibble::tibble(
      platform = "huggingface", kind = kind,
      id = as.character(model_id), full_name = as.character(model_id),
      sha = as.character(item$sha %||% NA_character_),
      name = ifelse(is.na(model_id), NA_character_, sub("^.*/", "", model_id)),
      description = item$cardData$description %||% item$description %||% NA_character_,
      url = ifelse(is.na(model_id), NA_character_, paste0(
        "https://huggingface.co/", if (identical(kind, "models")) "" else paste0(kind, "/"), model_id
      )),
      owner = owner,
      language = NA_character_, stars = as.integer(item$likes %||% 0L),
      updated_at = item$lastModified %||% NA_character_,
      topics = list(unlist(item$tags %||% character(), use.names = FALSE)),
      readme = NA_character_,
      # (pt) Sinais de maturidade para R/trl.R; a licença vem da tag `license:`.
      downloads = suppressWarnings(as.integer(item$downloads %||% NA_integer_)),
      created_at = item$createdAt %||% NA_character_,
      license = {
        tags <- unlist(item$tags %||% character(), use.names = FALSE)
        found <- sub("^license:", "", tags[startsWith(tags, "license:")])
        if (length(found)) found[[1]] else NA_character_
      },
      pipeline_tag = item$pipeline_tag %||% NA_character_
    )
  })
}

coletar_hf <- function(seeds_path = "config/seeds.yml",
                       root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
                       request_fn = NULL, account, budget, max_pages = 1L) {
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  if (length(max_pages) != 1L || is.na(max_pages) || max_pages != 1L) {
    stop("A amostra exploratória aceita exatamente uma página do Hugging Face.", call. = FALSE)
  }
  seeds <- yaml::yaml.load(readr::read_file(seeds_path, locale = readr::locale(encoding = "UTF-8")))
  accounts <- hf_seed_accounts(seeds)
  if (length(account) != 1L || is.na(account) || !nzchar(account) || !(account %in% accounts)) {
    stop("Escolha exatamente uma conta Hugging Face já listada em config/seeds.yml.", call. = FALSE)
  }
  # full=true is documented by the Hub client as including the commit SHA,
  # which lets README reads pin the exact revision instead of mutable main.
  items <- hf_collect_query("models", list(author = account, limit = 100, full = "true"), root,
                            request_fn, max_pages = 1L, budget)
  pagination <- attr(items, "pagination_summary")
  result <- hf_normalize_items(items, "models") |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  result <- aplicar_ids_sementes(result, seeds)
  attr(result, "radar_metadata") <- list(
    provider = "huggingface",
    account = account,
    kind = "models",
    limit = 100L,
    pagination = pagination,
    account_check = if (length(items)) {
      "A API retornou modelos para a conta-semente."
    } else {
      "A lista veio vazia; não permite distinguir conta sem modelos de conta não resolvida."
    },
    coverage = "uma página; não representa cobertura total da conta",
    budget = radar_resumo_orcamento(budget)
  )
  result
}
