#!/usr/bin/env Rscript
# (pt) Gera, no cache externo, a planilha de revisão do autor e a planilha no
#      formato do formulário do BBSIA para uma rodada já classificada no
#      Decifra. Apenas carrega e chama funções de R/.
# (en) Builds the review and form workbooks for a classified round.
# Uso: Rscript scripts/02_planilhas.R config/rodadas/<rodada>.yml <export-do-decifra.csv>
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) stop("Informe o arquivo da rodada e a exportação CSV do Decifra.", call. = FALSE)
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) sys.source(file, envir = .GlobalEnv)

root <- Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")
radar_validate_cache_root(root)
rodada <- radar_ler_rodada(args[[1]])
exports <- file.path(radar_cache_root(root), "bbsia-radar", "exports")
corpus <- readr::read_csv(file.path(exports, paste0(rodada$run_id, "-corpus.csv")),
                          col_types = readr::cols(.default = "c"), progress = FALSE)
candidatos_path <- file.path(exports, paste0(rodada$run_id, "-candidatos.csv"))
if (!file.exists(candidatos_path)) {
  readr::write_csv(radar_tabela_candidatos(radar_reconstruir_rodada(args[[1]], root)), candidatos_path, na = "")
}
candidatos <- readr::read_csv(candidatos_path, col_types = readr::cols(.default = "c"), progress = FALSE)
candidatos$stars <- as.integer(candidatos$stars)
if ("downloads" %in% names(candidatos)) candidatos$downloads <- as.integer(candidatos$downloads)
if ("archived" %in% names(candidatos)) candidatos$archived <- as.logical(candidatos$archived)
if ("fork" %in% names(candidatos)) candidatos$fork <- as.logical(candidatos$fork)
decifra <- radar_ler_decifra(args[[2]])

revisao <- radar_planilha_revisao(corpus, candidatos, decifra)
formulario <- radar_montar_planilha_formulario(candidatos, decifra, rodada$run_id, corpus = corpus)
writexl::write_xlsx(revisao$autor, file.path(exports, paste0(rodada$run_id, "-revisao-autor.xlsx")))
writexl::write_xlsx(revisao$maquina, file.path(exports, paste0(rodada$run_id, "-revisao-maquina.xlsx")))
writexl::write_xlsx(list(formulario = formulario), file.path(exports, paste0(rodada$run_id, "-formulario.xlsx")))
cat("Planilhas gravadas no cache externo:", nrow(formulario), "soluções.\n")
