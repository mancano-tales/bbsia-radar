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
  id <- as.character(id)
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
  if (is.null(anterior)) {
    anterior <- tibble::tibble(artifact_id = character(), content_hash = character(), status = character())
  }
  radar_validar_observacoes(atual)
  radar_validar_observacoes(anterior)
  ids <- union(anterior$artifact_id, atual$artifact_id)
  if (!length(ids)) {
    return(tibble::tibble(run_id = character(), artifact_id = character(),
                          evento = character(), content_hash = character()))
  }
  previous_index <- match(ids, anterior$artifact_id)
  current_index <- match(ids, atual$artifact_id)
  event <- vapply(seq_along(ids), function(i) {
    before <- previous_index[[i]]
    now <- current_index[[i]]
    if (is.na(now)) return("ausente_da_busca")
    if (identical(atual$status[[now]], "http_404")) return("http_404")
    if (is.na(before)) return("novo")
    if (identical(anterior$status[[before]], "http_404")) return("reapareceu")
    if (identical(anterior$content_hash[[before]], atual$content_hash[[now]])) {
      return("inalterado")
    }
    "alterado"
  }, character(1))
  hash <- vapply(current_index, function(i) {
    if (is.na(i)) return(NA_character_)
    as.character(atual$content_hash[[i]])
  }, character(1))
  tibble::tibble(run_id = run_id, artifact_id = ids, evento = event, content_hash = hash)
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
