# Probable TRL from public metadata / TRL provável por metadados públicos.
#
# (pt) O codebook (seção `maturidade`) pede uma ESTIMATIVA, revisável, em
#      faixas: 1-3 (ideia ou prova de conceito), 4-6 (protótipo validado) e
#      7-9 (em operação). A cautela do próprio codebook vale aqui: estrelas,
#      downloads, releases e atividade não comprovam uso externo nem TRL 7-9.
#      Por isso esta função só separa 1-3 de 4-6; 7-9 exige uso institucional
#      declarado e citável, que só a revisão humana confirma. Cada linha traz
#      os sinais usados, para que a estimativa possa ser conferida.
# (en) Metadata-only estimate that never claims 7-9; every row lists the
#      signals behind it so a reviewer can check or overturn it.

RADAR_TRL_LIMIARES <- list(
  readme_documentado = 1500L, # caracteres: README com mais que um parágrafo
  estrelas = 10L,             # GitHub/GitLab stars ou likes do Hugging Face
  downloads = 100L,           # downloads do Hugging Face no período da API
  dias_ativo = 365L           # "ativo" = atividade nos últimos 12 meses
)

radar_ultima_atividade <- function(candidatos) {
  n <- nrow(candidatos)
  pushed <- if ("pushed_at" %in% names(candidatos)) candidatos$pushed_at else rep(NA_character_, n)
  updated <- if ("updated_at" %in% names(candidatos)) candidatos$updated_at else rep(NA_character_, n)
  # GitHub `pushed_at` is the last push; `updated_at` also moves on metadata
  # edits, so it is only the fallback (and the only field HF/GitLab provide).
  ifelse(!is.na(pushed) & nzchar(pushed), pushed, updated)
}

radar_estimar_trl <- function(candidatos, referencia = Sys.Date(),
                              limiares = RADAR_TRL_LIMIARES) {
  n <- nrow(candidatos)
  col <- function(name, default) if (name %in% names(candidatos)) candidatos[[name]] else rep(default, n)
  readme <- col("readme", NA_character_)
  readme_len <- ifelse(is.na(readme), 0L, nchar(readme, type = "chars"))
  stars <- suppressWarnings(as.integer(col("stars", NA_integer_)))
  downloads <- suppressWarnings(as.integer(col("downloads", NA_integer_)))
  archived <- as.logical(col("archived", FALSE))
  archived[is.na(archived)] <- FALSE
  fork <- as.logical(col("fork", FALSE))
  fork[is.na(fork)] <- FALSE

  # All three APIs return ISO 8601; anything else becomes NA instead of an error.
  ultima <- as.Date(substr(radar_ultima_atividade(candidatos), 1L, 10L), format = "%Y-%m-%d",
                    optional = TRUE)
  dias <- as.integer(as.Date(referencia) - ultima)
  ativo <- ifelse(is.na(dias), NA_character_, ifelse(dias <= limiares$dias_ativo, "sim", "nao"))

  documentado <- readme_len >= limiares$readme_documentado
  uso <- (!is.na(stars) & stars >= limiares$estrelas) |
    (!is.na(downloads) & downloads >= limiares$downloads)
  # A model card with `model-index` or a README reporting metrics counts as
  # "avaliação ou resultados reportados" in the codebook's 4-6 band.
  avaliacao <- !is.na(readme) &
    grepl("model-index|\\bF1\\b|acur[aá]cia|accuracy|benchmark|avalia[cç][aã]o", readme,
          ignore.case = TRUE)

  # A fork inherits README and metrics from its upstream, so they say nothing
  # about the fork itself (codebook exclusion `fork_sem_mudanca`).
  trl <- ifelse(readme_len == 0L, "indeterminado",
                ifelse(documentado & (uso | avaliacao) & !archived & !fork, "4-6", "1-3"))
  sinais <- vapply(seq_len(n), function(i) {
    parts <- c(
      if (readme_len[[i]] == 0L) "sem README lido" else
        paste0("README com ", readme_len[[i]], " caracteres",
               if (documentado[[i]]) " (documentado)" else " (curto)"),
      if (!is.na(stars[[i]])) paste0(stars[[i]], " estrelas/likes"),
      if (!is.na(downloads[[i]])) paste0(downloads[[i]], " downloads"),
      if (isTRUE(avaliacao[[i]])) "resultados ou avaliação reportados",
      if (is.na(ativo[[i]])) "sem data de atividade" else
        paste0("última atividade há ", dias[[i]], " dias"),
      if (archived[[i]]) "arquivado",
      if (fork[[i]]) "fork (sinais do original não contam)"
    )
    paste(parts, collapse = "; ")
  }, character(1))

  tibble::tibble(trl_provavel = trl, trl_sinais = sinais, ativo = ativo,
                 trl_regra = "metadados; 7-9 só com uso institucional declarado e revisão humana")
}
