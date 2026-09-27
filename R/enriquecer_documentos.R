# Bounded README/model-card enrichment / Enriquecimento limitado de documentos.
#
# (pt) Esta função escolhe no máximo dez URLs distintas em ordem canônica,
#      registra a seleção no retorno e compartilha o orçamento entre GitHub e
#      Hugging Face. URLs das soluções brasileiras da lista curada podem ser
#      priorizadas para que façam parte da amostra.
# (en) This function selects at most ten distinct URLs in canonical order,
#      records the selection in its return value, and shares one budget across
#      Hugging Face. URLs for Brazilian solutions from the curated list can be
#      prioritized so they are represented in the sample.

coletar_readmes_exploratorios <- function(
    repositories,
    root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
    request_github_fn = NULL,
    request_hf_fn = NULL,
    priority_urls = character(),
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
  if (!is.character(priority_urls) || anyNA(priority_urls) ||
      any(!nzchar(trimws(priority_urls)))) {
    stop("priority_urls precisa ser um vetor de URLs não vazias.", call. = FALSE)
  }

  canonical <- tolower(trimws(repositories$url))
  ordered <- repositories[order(canonical, repositories$url), , drop = FALSE]
  ordered_canonical <- canonical[order(canonical, repositories$url)]
  eligible <- ordered[!duplicated(ordered_canonical), , drop = FALSE]
  # Apply the author's explicit priority list only after URL deduplication.
  # The remaining candidates keep the original canonical ordering, making the
  # result repeatable while ensuring known Brazilian examples occupy the sample.
  # (pt) As prioridades só alteram a ordem após deduplicar URLs. Os demais
  #      candidatos continuam em ordem canônica, para repetibilidade e para
  #      garantir presença dos exemplos brasileiros conhecidos.
  eligible_canonical <- tolower(trimws(eligible$url))
  priority_canonical <- unique(tolower(trimws(priority_urls)))
  prioritized <- eligible[eligible_canonical %in% priority_canonical, , drop = FALSE]
  other <- eligible[!(eligible_canonical %in% priority_canonical), , drop = FALSE]
  ordered_eligible <- dplyr::bind_rows(prioritized, other)
  remaining <- budget$max_documentos - length(budget$documentos)
  selected <- utils::head(ordered_eligible, max(0L, remaining))
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
      excluded_by_limit = nrow(eligible) - nrow(selected),
      prioritized_selected = sum(tolower(selected$url) %in% priority_canonical)
    ),
    coverage = paste(
      "URLs prioritárias primeiro, demais em ordem canônica; no máximo dez README/model cards"
    )
  )
}
