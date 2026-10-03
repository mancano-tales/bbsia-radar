#!/usr/bin/env Rscript
# (pt) Publica em data/ o piloto revisado: lê do cache externo o corpus, os
#      candidatos, a exportação do Decifra, o manifesto e o gabarito adjudicado
#      do autor, e a curadoria de config/solucoes_piloto.yml. Só chama funções.
# (en) Writes the reviewed pilot into data/ from cache inputs and curation.
# Uso: Rscript scripts/03_publicar.R <run_id> <commit-do-decifra> <modelo>
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3L) stop("Informe run_id, commit do Decifra e modelo usado.", call. = FALSE)
for (file in list.files("R", pattern = "\\.R$", full.names = TRUE)) sys.source(file, envir = .GlobalEnv)

root <- Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", "")
radar_validate_cache_root(root)
run_id <- args[[1]]
cache <- file.path(radar_cache_root(root), "bbsia-radar")
ler <- function(nome) readr::read_csv(file.path(cache, "exports", paste0(run_id, nome)),
                                      col_types = readr::cols(.default = "c"), progress = FALSE)
corpus <- ler("-corpus.csv")
candidatos <- ler("-candidatos.csv")
candidatos$stars <- as.integer(candidatos$stars)
if ("downloads" %in% names(candidatos)) candidatos$downloads <- as.integer(candidatos$downloads)
for (col in intersect(c("archived", "fork"), names(candidatos))) candidatos[[col]] <- as.logical(candidatos[[col]])
gold <- ler("-revisao-adjudicada.csv")
maquina <- radar_ler_decifra(file.path(cache, "exports", paste0(run_id, "-decifra.csv")))
manifesto <- jsonlite::read_json(file.path(cache, "runs", paste0(run_id, ".json")), simplifyVector = TRUE)
solucoes <- radar_ler_solucoes("config/solucoes_piloto.yml")
codebook <- yaml::yaml.load(readr::read_file("config/codebook.yml", locale = readr::locale(encoding = "UTF-8")))
decifra <- list(commit = args[[2]], modelo = args[[3]], codebook_version = codebook$versao,
                extracoes = nrow(maquina), falhas = sum(maquina$falhou))

res <- radar_publicar_piloto(gold, maquina, candidatos, corpus, solucoes, manifesto, decifra,
                             out_dir = "data", referencia = as.Date(substr(manifesto$timestamp_utc, 1, 10)))
writeLines(radar_relatorio_piloto_md(res, manifesto, decifra), "report/_piloto.md", useBytes = TRUE)
cat("Publicado em data/:", nrow(res$solucoes), "soluções,", nrow(res$artefatos), "artefatos.\n")
