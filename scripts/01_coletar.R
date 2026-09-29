#!/usr/bin/env Rscript
# (pt) Ponto de entrada da rodada: apenas carrega e chama funções de R/.
# (en) Run entry point: only loads and calls functions from R/.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Informe o caminho do arquivo de rodada.", call. = FALSE)
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) sys.source(file, envir = .GlobalEnv)
radar_executar_rodada(args[[1]])
