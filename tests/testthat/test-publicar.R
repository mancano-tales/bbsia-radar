publicar_fixtures <- function() {
  gold <- tibble::tibble(
    id = c("github:1", "huggingface:models:org/m1", "huggingface:models:org/m2", "github:9"),
    e_ia = c("sim", "sim", "sim", "nao"), brasileira = c("sim", "sim", "sim", "nao"),
    ptbr = c("sim", "nao", "nao", "nao"), revisor = "autor",
    adjudicacao = c("", "ptbr sim -> nao", "", ""))
  maquina <- tibble::tibble(
    id = rep(gold$id, each = 5),
    variavel = rep(c("e_ia", "brasileira", "ptbr", "tipo_artefato", "area_problema"), 4),
    valor = c("sim", "sim", "sim", "aplicacao", "saude",
              "sim", "incerto", "nao", "modelo", NA,
              "sim", NA, "incerto", "modelo", NA,
              "incerto", "incerto", "incerto", "aplicacao", NA),
    justificativa = "r", evidencia = "trecho do README de terceiros", falhou = FALSE)
  candidatos <- tibble::tibble(
    id = gold$id, platform = c("github", "huggingface", "huggingface", "github"),
    name = c("A", "m1", "m2", "z"), url = c("https://github.com/a/a", "https://huggingface.co/org/m1",
                                            "https://huggingface.co/org/m2", "https://github.com/z/z"),
    owner = c("a", "org", "org", "z"), stars = c(20L, 1L, 1L, 0L), downloads = c(NA, 500L, 10L, NA),
    license = c("MIT", "apache-2.0", "apache-2.0", NA),
    pushed_at = c("2026-09-01T00:00:00Z", NA, NA, NA),
    updated_at = c("2026-09-01T00:00:00Z", "2026-08-01T00:00:00Z", "2026-08-01T00:00:00Z", NA))
  meta <- "\n\nNome: x\nArtefatos: u\nTópicos/tags: "
  corpus <- tibble::tibble(id = gold$id, text = paste0(c(strrep("doc ", 600), "card model-index", "card", ""), meta),
                           source_urls = candidatos$url)
  solucoes <- list(rodada = "teste_piloto", solucoes = list(
    list(solution_id = "s-a", nome = "Solução A", artefatos = list("github:1"),
         problema_resumo = "Ajuda alguém a fazer algo.", justificativa = "Um artefato."),
    list(solution_id = "s-familia", nome = "Família M", artefatos = list("huggingface:models:org/m1", "huggingface:models:org/m2"),
         problema_resumo = "Ajuda outra pessoa.", justificativa = "Mesma família.", nota = "Modelos em inglês.")))
  manifesto <- list(run_id = "teste_piloto", timestamp_utc = "2026-09-29T15:00:00Z",
                    consultas = list(github = list(contas = "a")), totais = list(github = 3L, huggingface = 2L, gitlab = 0L, corpus = 4L),
                    tentativas_usadas = 10L, documentos_selecionados = 4L, status_http = list(`github:200` = 3L),
                    contas_hf = list(org = "com_modelos"), collector_commit = "abc1234")
  decifra <- list(commit = "4df06df", modelo = "gemini-3.8-flash-high", codebook_version = "0.2.2",
                  extracoes = 20L, falhas = 0L)
  list(gold = gold, maquina = maquina, candidatos = candidatos, corpus = corpus,
       solucoes = solucoes, manifesto = manifesto, decifra = decifra)
}

test_that("agreement treats machine 'incerto' as not-yes and excludes machine failures", {
  f <- publicar_fixtures()
  conc <- radar_concordancia(f$gold, radar_decifra_largo(f$maquina))
  e_ia <- conc[conc$variavel == "e_ia", ]
  expect_equal(c(e_ia$precisao, e_ia$recall, e_ia$kappa), c(1, 1, 1))
  bras <- conc[conc$variavel == "brasileira", ]
  expect_equal(bras$n, 3L)
  expect_equal(bras$falhas_maquina, 1L)
  expect_equal(bras$recall, 0.5)
})

test_that("the public dataset follows the v1 contract and never copies third-party text", {
  f <- publicar_fixtures()
  out <- tempfile("data")
  res <- radar_publicar_piloto(f$gold, f$maquina, f$candidatos, f$corpus, f$solucoes, f$manifesto,
                               f$decifra, out_dir = out, referencia = as.Date("2026-09-29"))
  expect_true(all(file.exists(file.path(out, c("solutions.csv", "solution_artifacts.csv", "snapshot_atual.csv",
                                               "runs/teste_piloto.json", "evidence/teste_piloto.jsonl",
                                               "relatorios/teste_piloto-concordancia.csv")))))
  snap <- readr::read_csv(file.path(out, "snapshot_atual.csv"), show_col_types = FALSE)
  expect_equal(snap$solution_id, c("s-a", "s-familia"))
  expect_equal(snap$ptbr, c("sim", "nao"))
  expect_match(snap$artefatos[[2]], "org/m1 \\| https://huggingface.co/org/m2")
  todo <- paste(vapply(list.files(out, recursive = TRUE, full.names = TRUE), readr::read_file, character(1)), collapse = "\n")
  expect_false(grepl("trecho do README de terceiros", todo, fixed = TRUE))
  expect_false(grepl("doc doc doc", todo, fixed = TRUE))
  evid <- lapply(readLines(file.path(out, "evidence/teste_piloto.jsonl")), jsonlite::fromJSON)
  expect_equal(length(evid), 3L * 6L)
  revisao <- vapply(evid, `[[`, character(1), "revisao")
  campos <- vapply(evid, `[[`, character(1), "campo")
  expect_true(all(revisao[campos %in% RADAR_MARCACOES] == "revisado"))
  expect_true(all(revisao[!campos %in% RADAR_MARCACOES] == "proposto"))
  run <- jsonlite::read_json(file.path(out, "runs/teste_piloto.json"))
  expect_equal(run$revisao_humana$adjudicacoes, 1L)
  expect_null(run$corpus_path)
})

test_that("curation must cover exactly the artifacts the author included", {
  f <- publicar_fixtures()
  f$solucoes$solucoes[[2]]$artefatos <- list("huggingface:models:org/m1")
  expect_error(radar_publicar_piloto(f$gold, f$maquina, f$candidatos, f$corpus, f$solucoes, f$manifesto,
                                     f$decifra, out_dir = tempfile()), "sem solução curada")
  f <- publicar_fixtures()
  f$solucoes$solucoes[[1]]$artefatos <- list("github:1", "github:9")
  expect_error(radar_publicar_piloto(f$gold, f$maquina, f$candidatos, f$corpus, f$solucoes, f$manifesto,
                                     f$decifra, out_dir = tempfile()), "não incluiu")
})

test_that("the generated report uses readable labels and the published numbers", {
  f <- publicar_fixtures()
  res <- radar_publicar_piloto(f$gold, f$maquina, f$candidatos, f$corpus, f$solucoes, f$manifesto,
                               f$decifra, out_dir = tempfile(), referencia = as.Date("2026-09-29"))
  md <- paste(radar_relatorio_piloto_md(res, f$manifesto, f$decifra), collapse = "\n")
  expect_match(md, "Não editar à mão")
  expect_match(md, "| Soluções, depois de agrupar as variantes da mesma família | 2 |", fixed = TRUE)
  expect_match(md, "É adaptada ao português do Brasil?", fixed = TRUE)
  expect_match(md, "Aplicação")
  expect_false(grepl("aplicacao", md, fixed = TRUE))
  expect_equal(radar_licenca_legivel(c("NOASSERTION", NA, "MIT")), c("não declarada", "—", "MIT"))
})

test_that("the curated pilot file is consistent", {
  spec <- radar_ler_solucoes(file.path(repo_root, "config", "solucoes_piloto.yml"))
  expect_equal(length(spec$solucoes), 8L)
  expect_true(all(startsWith(purrr::map_chr(spec$solucoes, "solution_id"), "s-")))
  expect_true(all(nzchar(purrr::map_chr(spec$solucoes, "problema_resumo"))))
})

test_that("agreement survives a variable where every machine answer failed", {
  f <- publicar_fixtures()
  m <- radar_decifra_largo(f$maquina)
  m$ptbr <- NA_character_
  conc <- radar_concordancia(f$gold, m)
  ptbr <- conc[conc$variavel == "ptbr", ]
  expect_equal(ptbr$n, 0L)
  expect_true(is.na(ptbr$kappa) && is.na(ptbr$precisao))
})
