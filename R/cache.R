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

radar_repository_root <- function() {
  current <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
  repeat {
    marker <- file.path(current, ".data-source")
    if (file.exists(marker)) return(normalizePath(current, winslash = "/", mustWork = TRUE))
    parent <- dirname(current)
    if (identical(parent, current)) {
      stop("Não encontrei .data-source para validar a raiz do repositório.", call. = FALSE)
    }
    current <- parent
  }
}

radar_validate_cache_root <- function(root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = "")) {
  if (length(root) != 1L || is.na(root) || !nzchar(root)) {
    stop("Defina MANCANO_BBSIA_RADAR_ROOT antes da coleta; cache fora do git é obrigatório.",
         call. = FALSE)
  }
  if (!dir.exists(root)) {
    stop("A raiz de cache precisa existir antes da coleta.", call. = FALSE)
  }
  resolved <- normalizePath(root, winslash = "/", mustWork = TRUE)
  repository <- radar_repository_root()
  root_key <- tolower(sub("/+$", "", resolved))
  repository_key <- tolower(sub("/+$", "", repository))
  if (identical(root_key, repository_key) || startsWith(root_key, paste0(repository_key, "/"))) {
    stop("A raiz de cache não pode ficar dentro do checkout.", call. = FALSE)
  }
  probe <- tempfile(pattern = ".bbsia-radar-write-check-", tmpdir = resolved)
  writable <- tryCatch(file.create(probe), warning = function(w) FALSE, error = function(e) FALSE)
  if (file.exists(probe)) unlink(probe)
  if (!isTRUE(writable)) stop("A raiz de cache não está gravável.", call. = FALSE)
  invisible(resolved)
}

# (pt) Um objeto mutável é compartilhado por descoberta e enriquecimento para
#      impor o mesmo teto em toda a rodada. São reservadas até 25 tentativas:
#      duas buscas GitHub, uma listagem HF, duas buscas GitLab e até duas
#      tentativas por um dos dez documentos selecionados (HEAD+GET no GitLab
#      ou GET mais um redirecionamento no HF). Nenhuma função repete falhas.
# (en) Discovery and enrichment share one budget. The exploratory ceiling is
#      25 reserved attempts: two GitHub searches, one HF listing, two GitLab
#      searches, and up to two attempts for each of ten documents (GitLab
#      HEAD+GET or an HF GET plus one redirect). Clients never retry failures.
radar_novo_orcamento <- function(max_tentativas = 25L, max_documentos = 10L) {
  tentativas_n <- suppressWarnings(as.integer(max_tentativas))
  documentos_n <- suppressWarnings(as.integer(max_documentos))
  if (length(tentativas_n) != 1L || is.na(tentativas_n) ||
      !is.numeric(max_tentativas) || max_tentativas != tentativas_n ||
      tentativas_n < 1L || tentativas_n > 25L) {
    stop("max_tentativas precisa estar entre 1 e 25.", call. = FALSE)
  }
  if (length(documentos_n) != 1L || is.na(documentos_n) ||
      !is.numeric(max_documentos) || max_documentos != documentos_n ||
      documentos_n < 0L || documentos_n > 10L) {
    stop("max_documentos precisa estar entre 0 e 10.", call. = FALSE)
  }
  budget <- new.env(parent = emptyenv())
  budget$radar_budget <- TRUE
  budget$max_tentativas <- tentativas_n
  budget$max_documentos <- documentos_n
  budget$tentativas_reservadas <- 0L
  budget$requisicoes_logicas <- 0L
  budget$documentos <- character()
  budget$ledger <- list()
  budget
}

radar_validar_orcamento <- function(budget) {
  if (!is.environment(budget) || !isTRUE(budget$radar_budget)) {
    stop("Crie e compartilhe o orçamento com radar_novo_orcamento().", call. = FALSE)
  }
  if (length(budget$max_tentativas) != 1L || is.na(budget$max_tentativas) ||
      budget$max_tentativas < 1L || budget$max_tentativas > 25L ||
      length(budget$max_documentos) != 1L || is.na(budget$max_documentos) ||
      budget$max_documentos < 0L || budget$max_documentos > 10L ||
      budget$tentativas_reservadas < 0L || budget$tentativas_reservadas > budget$max_tentativas ||
      length(budget$documentos) > budget$max_documentos) {
    stop("O orçamento HTTP está inválido ou excede o teto exploratório de 25 tentativas.", call. = FALSE)
  }
  invisible(budget)
}

radar_reservar_requisicao <- function(budget, provider, recurso, tentativas = 1L) {
  radar_validar_orcamento(budget)
  tentativas <- as.integer(tentativas)
  if (length(tentativas) != 1L || is.na(tentativas) || tentativas < 1L || tentativas > 2L) {
    stop("Cada chamada pode reservar uma ou duas tentativas HTTP.", call. = FALSE)
  }
  if (budget$tentativas_reservadas + tentativas > budget$max_tentativas) {
    stop("Orçamento HTTP esgotado; a coleta foi interrompida antes da próxima chamada.", call. = FALSE)
  }
  budget$tentativas_reservadas <- budget$tentativas_reservadas + tentativas
  budget$requisicoes_logicas <- budget$requisicoes_logicas + 1L
  budget$ledger[[length(budget$ledger) + 1L]] <- list(
    provider = provider, resource = recurso, tentativas_reservadas = tentativas
  )
  invisible(budget)
}

radar_reservar_documentos <- function(budget, provider, ids) {
  radar_validar_orcamento(budget)
  ids <- unique(as.character(ids[!is.na(ids) & nzchar(ids)]))
  novas <- setdiff(paste(provider, ids, sep = ":"), budget$documentos)
  if (length(budget$documentos) + length(novas) > budget$max_documentos) {
    stop("O limite global de dez README/model cards seria excedido.", call. = FALSE)
  }
  budget$documentos <- c(budget$documentos, novas)
  invisible(budget)
}

radar_resumo_orcamento <- function(budget) {
  radar_validar_orcamento(budget)
  list(
    tentativas_reservadas = budget$tentativas_reservadas,
    limite_tentativas = budget$max_tentativas,
    requisicoes_logicas = budget$requisicoes_logicas,
    documentos_selecionados = length(budget$documentos),
    limite_documentos = budget$max_documentos,
    chamadas = budget$ledger
  )
}

radar_verificar_status_http <- function(status, provider, resource) {
  status <- as.integer(status)
  if (!is.na(status) && status >= 200L && status < 300L) return(invisible(status))
  classe <- paste0("http_error_", if (is.na(status)) "unknown" else status)
  mensagem <- paste0(provider, " respondeu HTTP ", if (is.na(status)) "desconhecido" else status,
                     " para ", resource,
                     "; a rodada não faz retentativas automáticas.")
  stop(structure(list(message = mensagem, call = NULL), class = c(classe, "error", "condition")))
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

radar_cached <- function(key, fetch, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = ""),
                        refresh = FALSE, refresh_if = NULL) {
  cache_path <- radar_cache_path(key, root)
  cached <- if (!refresh) radar_cache_read(key, root) else NULL
  if (!is.null(cached)) {
    cached_at <- file.info(cache_path)$mtime[[1]]
    should_refresh <- is.function(refresh_if) && isTRUE(refresh_if(cached, cached_at))
    if (!should_refresh) return(cached)
  }
  value <- redact_email_data(fetch())
  radar_cache_write(key, value, root)
  value
}
