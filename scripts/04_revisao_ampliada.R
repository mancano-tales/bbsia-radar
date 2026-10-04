#!/usr/bin/env Rscript
# (pt) Revisão de inclusão da rodada completa (protocolo do autor, 2026-10-03):
#      todos os documentos que a máquina propõe incluir mais uma amostra
#      aleatória dos demais, embaralhados. A planilha do autor não mostra o
#      grupo; o grupo vai para um CSV separado, usado só na análise. Tudo fica
#      no cache externo. Apenas carrega e chama funções de R/.
# (en) Blind inclusion review: shuffled sample, group kept in a separate file.
# Uso: Rscript scripts/04_revisao_ampliada.R <run_id> <export-do-decifra.csv> [n_amostra]
args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% c(2L, 3L)) stop("Informe run_id, a exportação do Decifra e, opcionalmente, n_amostra.", call. = FALSE)
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) sys.source(file, envir = .GlobalEnv)

root <- Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")
radar_validate_cache_root(root)
run_id <- args[[1]]
exports <- file.path(radar_cache_root(root), "bbsia-radar", "exports")
ler <- function(nome) readr::read_csv(file.path(exports, paste0(run_id, nome)),
                                      col_types = readr::cols(.default = "c"), progress = FALSE)
corpus <- ler("-corpus.csv")
candidatos <- ler("-candidatos.csv")
maquina <- radar_ler_decifra(args[[2]])
n_amostra <- if (length(args) == 3L) as.integer(args[[3]]) else 30L

amostra <- radar_amostra_revisao(radar_decifra_largo(maquina), n_amostra = n_amostra)
revisao <- radar_planilha_revisao(corpus, candidatos, maquina, ids = amostra$id)
writexl::write_xlsx(revisao$autor, file.path(exports, paste0(run_id, "-revisao-autor.xlsx")))
writexl::write_xlsx(revisao$maquina, file.path(exports, paste0(run_id, "-revisao-maquina.xlsx")))
readr::write_csv(amostra, file.path(exports, paste0(run_id, "-revisao-grupos.csv")))
cat("Revisão gravada:", nrow(amostra), "documentos (",
    sum(amostra$grupo == "proposto_pela_maquina"), "propostos pela máquina +",
    sum(amostra$grupo == "amostra_do_resto"), "da amostra).\n")
