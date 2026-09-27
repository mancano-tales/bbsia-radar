# Bounded README/model-card enrichment / Enriquecimento limitado de documentos.
#
# (pt) Esta função escolhe no máximo dez URLs distintas, reserva primeiro um
#      documento por plataforma disponível e completa o limite em ordem
#      canônica. Compartilha o orçamento entre GitHub, Hugging Face e GitLab.
#      Só modelos HF podem ser enriquecidos nesta rodada.
# (en) This function selects at most ten distinct URLs, first reserving one
#      document per available platform and filling the remaining slots in
#      canonical order. It shares one budget across GitHub, Hugging Face, and
#      GitLab. Only HF models are eligible in this run.

coletar_readmes_exploratorios <- function(
    repositories,
    root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", ""),
    request_github_fn = NULL,
    request_hf_fn = NULL,
    request_gitlab_fn = NULL,
    budget) {
  required <- c("platform", "url")
  if (!all(required %in% names(repositories))) {
    stop("repositories precisa de platform e url.", call. = FALSE)
  }
  radar_validar_orcamento(budget)
  radar_validate_cache_root(root)
  if (anyNA(repositories$platform) || any(!(repositories$platform %in% c("github", "huggingface", "gitlab")))) {
    stop("platform aceita somente github, huggingface ou gitlab.", call. = FALSE)
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
  if (any(repositories$platform == "gitlab") && !("id" %in% names(repositories))) {
    stop("Candidatos GitLab precisam da coluna id.", call. = FALSE)
  }

  canonical <- tolower(trimws(repositories$url))
  ordered <- repositories[order(canonical, repositories$url), , drop = FALSE]
  ordered_canonical <- canonical[order(canonical, repositories$url)]
  eligible <- ordered[!duplicated(ordered_canonical), , drop = FALSE]
  remaining <- budget$max_documentos - length(budget$documentos)
  platforms <- c("github", "huggingface", "gitlab")
  first_by_platform <- purrr::map_int(platforms, ~ match(.x, eligible$platform, nomatch = 0L))
  first_by_platform <- first_by_platform[first_by_platform > 0L]
  candidate_order <- c(first_by_platform, setdiff(seq_len(nrow(eligible)), first_by_platform))
  selected <- eligible[utils::head(candidate_order, max(0L, remaining)), , drop = FALSE]
  selected$selection_order <- seq_len(nrow(selected))

  github <- selected[selected$platform == "github", , drop = FALSE]
  hf <- selected[selected$platform == "huggingface", , drop = FALSE]
  gitlab <- selected[selected$platform == "gitlab", , drop = FALSE]
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
  if (nrow(gitlab)) {
    enriched[[length(enriched) + 1L]] <- coletar_readme_gitlab(
      gitlab, root = root, request_fn = request_gitlab_fn, budget = budget
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
    coverage = "Até um README/model card por plataforma disponível recebe prioridade; demais vagas seguem ordem canônica; no máximo dez"
  )
}
