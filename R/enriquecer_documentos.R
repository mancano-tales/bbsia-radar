# Bounded README/model-card enrichment / Enriquecimento limitado de documentos.
#
# (pt) Esta função escolhe no máximo dez URLs distintas em ordem canônica,
#      registra a seleção no retorno e compartilha o orçamento entre GitHub e
#      Hugging Face. Só modelos HF podem ser enriquecidos nesta primeira rodada.
# (en) This function selects at most ten distinct URLs in canonical order,
#      records the selection in its return value, and shares one budget across
#      GitHub and Hugging Face. Only HF models are eligible in this first run.

coletar_readmes_exploratorios <- function(
    repositories,
    root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
    request_github_fn = NULL,
    request_hf_fn = NULL,
    budget) {
  required <- c("platform", "url")
  if (!all(required %in% names(repositories))) {
    stop("repositories precisa de platform e url.", call. = FALSE)
  }
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  if (anyNA(repositories$platform) || any(!(repositories$platform %in% c("github", "huggingface")))) {
    stop("platform aceita somente github ou huggingface.", call. = FALSE)
  }
  if (anyNA(repositories$url) || any(!nzchar(repositories$url))) {
    stop("Todas as soluções precisam ter uma URL antes da seleção.", call. = FALSE)
  }
  if (any(repositories$platform == "huggingface") && !("kind" %in% names(repositories))) {
    stop("Candidatos Hugging Face precisam da coluna kind.", call. = FALSE)
  }
  if ("kind" %in% names(repositories) &&
      any(repositories$platform == "huggingface" &
          (is.na(repositories$kind) | repositories$kind != "models"))) {
    stop("A seleção exploratória só pode incluir models do Hugging Face.", call. = FALSE)
  }
  if (any(repositories$platform == "github") && !("full_name" %in% names(repositories))) {
    stop("Candidatos GitHub precisam da coluna full_name.", call. = FALSE)
  }
  if (any(repositories$platform == "huggingface") && !("id" %in% names(repositories))) {
    stop("Candidatos Hugging Face precisam da coluna id.", call. = FALSE)
  }

  canonical <- tolower(trimws(repositories$url))
  ordered <- repositories[order(canonical, repositories$url), , drop = FALSE]
  ordered_canonical <- canonical[order(canonical, repositories$url)]
  eligible <- ordered[!duplicated(ordered_canonical), , drop = FALSE]
  remaining <- budget$max_documentos - length(budget$documentos)
  selected <- utils::head(eligible, max(0L, remaining))
  selected$selection_order <- seq_len(nrow(selected))

  github <- selected[selected$platform == "github", , drop = FALSE]
  hf <- selected[selected$platform == "huggingface", , drop = FALSE]
  enriched <- list()
  if (nrow(github)) {
    enriched[[length(enriched) + 1L]] <- coletar_readme_github(
      github, root = root, request_fn = request_github_fn, budget = budget
    )
  }
  if (nrow(hf)) {
    enriched[[length(enriched) + 1L]] <- coletar_readme_hf(
      hf, root = root, request_fn = request_hf_fn, budget = budget
    )
  }
  documents <- if (length(enriched)) dplyr::bind_rows(enriched) else selected[0, , drop = FALSE]
  if (nrow(documents)) {
    documents$selection_order <- match(tolower(documents$url), tolower(selected$url))
    documents <- dplyr::arrange(documents, selection_order)
    documents$selection_order <- NULL
  }
  list(
    selected_urls = selected$url,
    documents = documents,
    budget = radar_resumo_orcamento(budget),
    selection = list(
      eligible_distinct = nrow(eligible),
      selected = nrow(selected),
      excluded_by_limit = nrow(eligible) - nrow(selected)
    ),
    coverage = "README/model cards selecionados pela URL em ordem canônica; no máximo dez"
  )
}
