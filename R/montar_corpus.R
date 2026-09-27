# Decifra corpus builder / Montador do corpus para o Decifra.
#
# (pt) Uma linha representa uma solução (não um repositório). A função junta
#      artefatos GitHub/Hugging Face por identidade normalizada e cria um texto
#      único citável: README/model card seguido de metadados explícitos em linhas.
#      As funções recebem os dados já coletados, o que mantém testes reproduzíveis
#      e evita rede implícita durante a montagem.
# (en) Each row represents one solution, not one repository. GitHub/Hugging Face
#      artifacts are grouped by normalized identity and converted into one
#      citable text: README/model card followed by explicit metadata lines.
#      Inputs are already collected, so corpus construction is deterministic and
#      never triggers hidden network requests.

normalizar_url_artefato <- function(url) {
  url <- sub("\\.git$", "", trimws(url))
  sub("/$", "", url)
}

aplicar_ids_sementes <- function(artifacts, seeds) {
  # Seed metadata is the only automatic cross-platform identity link. All
  # undiscovered relationships remain provisional instead of being guessed
  # from similar names or owners.
  if (!nrow(artifacts)) return(artifacts)
  artifacts$solution_id <- artifacts$url
  for (solution in seeds$gabarito %||% list()) {
    urls <- purrr::map_chr(solution$artefatos %||% list(), ~ normalizar_url_artefato(.x$url))
    match <- artifacts$url %in% urls
    artifacts$solution_id[match] <- as.character(solution$id_solucao)
  }
  artifacts
}

documento_solucao <- function(rows) {
  # Keep metadata in plain text because the Decifra prompt must be able to cite
  # both prose and API metadata as evidence, rather than seeing a detached JSON.
  descriptions <- unique(stats::na.omit(rows$description))
  owners <- unique(stats::na.omit(rows$owner))
  metadata <- c(
    paste0("Nome: ", rows$name[[1]]),
    paste0("Artefatos: ", paste(rows$url, collapse = " | ")),
    if (length(owners)) paste0("Responsável público: ", paste(owners, collapse = ", ")),
    if (length(descriptions)) paste0("Descrição da API: ", paste(descriptions, collapse = " | ")),
    paste0("Atualizado em: ", paste(unique(stats::na.omit(rows$updated_at)), collapse = " | ")),
    paste0("Tópicos/tags: ", paste(unique(unlist(rows$topics, use.names = FALSE)), collapse = ", "))
  )
  prose <- paste(unique(stats::na.omit(rows$readme)), collapse = "\n\n--- Documento do artefato ---\n\n")
  paste(c(prose, paste(metadata, collapse = "\n"))[nzchar(c(prose, paste(metadata, collapse = "\n")))], collapse = "\n\n")
}

montar_corpus <- function(github = tibble::tibble(), huggingface = tibble::tibble()) {
  artifacts <- dplyr::bind_rows(github, huggingface) |>
    dplyr::mutate(url = vapply(url, normalizar_url_artefato, character(1))) |>
    dplyr::filter(!is.na(url), nzchar(url)) |>
    dplyr::distinct(url, .keep_all = TRUE)
  if (!nrow(artifacts)) return(tibble::tibble(id = character(), text = character(), source_urls = character()))

  # A shared GitHub URL and HF model URL are linked only if either source's
  # `solution_id` has been manually assigned; otherwise each platform artifact
  # is a separate provisional solution, avoiding speculative identity merges.
  if (!"solution_id" %in% names(artifacts)) artifacts$solution_id <- artifacts$url
  artifacts |>
    dplyr::group_by(solution_id) |>
    dplyr::summarise(
      id = as.character(dplyr::first(solution_id)),
      text = documento_solucao(dplyr::pick(dplyr::everything())),
      source_urls = paste(url, collapse = " | "),
      .groups = "drop"
    ) |>
    dplyr::select(id, text, source_urls)
}

salvar_corpus_decifra <- function(corpus, path = NULL, root = Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")) {
  if (!all(c("id", "text") %in% names(corpus))) stop("Corpus deve conter colunas `id` e `text`.", call. = FALSE)
  # Generated corpus text is an intermediate working artifact, not a curated
  # dataset to commit by default. Keep it beside the external API cache unless
  # a caller explicitly supplies a reviewed output path.
  if (is.null(path)) path <- file.path(radar_cache_root(root), "bbsia-radar", "exports", "corpus-decifra.csv")
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  readr::write_csv(corpus, path, na = "")
  invisible(path)
}
