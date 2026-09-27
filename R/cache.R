# Cache helpers for public API responses / Funções auxiliares para o cache de APIs públicas.
#
# (pt) O arquivo `.data-source` marca que o repositório usa o resolvedor externo
#      de dados. O cache não é escrito neste checkout: cada execução exige que
#      `MANCANO_BBSIA_RADAR_ROOT` aponte para uma raiz de dados aprovada pelo
#      ambiente local. Assim, clones e PRs nunca carregam respostas brutas.
# (en) `.data-source` marks this repository as a consumer of the shared data
#      resolver. Raw API responses never live in this checkout: each run needs
#      `MANCANO_BBSIA_RADAR_ROOT` to point at a locally approved data root.

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0L) y else x

radar_data_source_spec <- function() {
  current <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    marker <- file.path(current, ".data-source")
    if (file.exists(marker)) {
      return(yaml::yaml.load(readr::read_file(marker, locale = readr::locale(encoding = "UTF-8"))))
    }
    parent <- dirname(current)
    if (identical(parent, current)) stop("Não encontrei .data-source no diretório atual nem nos pais.", call. = FALSE)
    current <- parent
  }
}

radar_cache_root <- function(root = "") {
  source <- radar_data_source_spec()
  root_name <- source$root_env %||% "MANCANO_BBSIA_RADAR_ROOT"
  if (!nzchar(root)) root <- Sys.getenv(root_name, unset = "")
  if (!nzchar(root)) {
    stop("Defina ", root_name, " no .Renviron local; cache fora do git é obrigatório.",
         call. = FALSE)
  }
  normalizePath(root, winslash = "/", mustWork = FALSE)
}

radar_cache_path <- function(key, root = "") {
  source <- radar_data_source_spec()
  root <- radar_cache_root(root)
  digest <- digest::digest(key, algo = "sha256", serialize = TRUE)
  file.path(root, source$cache_subdir %||% file.path("bbsia-radar", "api"), paste0(digest, ".json"))
}

radar_cache_read <- function(key, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = "")) {
  path <- radar_cache_path(key, root)
  if (!file.exists(path)) return(NULL)
  redact_email_data(jsonlite::read_json(path, simplifyVector = FALSE))
}

radar_cache_write <- function(key, value, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = "")) {
  path <- radar_cache_path(key, root)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # Write to a temporary sibling then rename: interrupted runs do not leave
  # a partial JSON file that a later offline run could mistake for a response.
  tmp <- tempfile(pattern = ".response-", tmpdir = dirname(path), fileext = ".json")
  on.exit(unlink(tmp), add = TRUE)
  # README/model-card prose and repository descriptions are user-authored text;
  # remove addresses there too, not just from structured email fields.
  jsonlite::write_json(redact_email_data(value), tmp, auto_unbox = TRUE, null = "null", pretty = FALSE)
  if (!file.rename(tmp, path)) stop("Não foi possível gravar cache em ", path, call. = FALSE)
  invisible(path)
}

redact_email_data <- function(value) {
  if (is.list(value)) {
    if (!is.null(names(value))) value <- value[!grepl("email", names(value), ignore.case = TRUE)]
    # GitHub's README endpoint returns UTF-8 text in a base64 `content` field.
    # Decode, redact, and re-encode it before either caching or returning it.
    if (identical(value$encoding, "base64") && is.character(value$content) && length(value$content) == 1L) {
      decoded <- rawToChar(jsonlite::base64_dec(gsub("\\s+", "", value$content)))
      decoded <- redact_email_data(decoded)
      value$content <- jsonlite::base64_enc(charToRaw(decoded))
    }
    return(lapply(value, redact_email_data))
  }
  if (is.character(value)) {
    return(gsub("[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[[:alpha:]]{2,}", "[EMAIL REDACTED]", value, perl = TRUE))
  }
  value
}

radar_cached <- function(key, fetch, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = ""), refresh = FALSE) {
  cached <- if (!refresh) radar_cache_read(key, root) else NULL
  if (!is.null(cached)) return(cached)
  value <- redact_email_data(fetch())
  radar_cache_write(key, value, root)
  value
}
