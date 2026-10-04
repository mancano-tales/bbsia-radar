candidatos_fixture <- function() {
  tibble::tibble(
    id = c("github:1", "huggingface:models:org/modelo", "github:3"),
    platform = c("github", "huggingface", "github"),
    name = c("Projeto A", "modelo", "rascunho"),
    url = c("https://github.com/a/a", "https://huggingface.co/org/modelo", "https://github.com/c/c"),
    owner = c("a", "org", "c"),
    readme = c(strrep("Instalação e exemplo de uso. ", 80), paste("model-index:", strrep("x", 1600)), NA),
    stars = c(25L, 3L, 0L),
    downloads = c(NA, 5000L, NA),
    pushed_at = c("2026-06-01T00:00:00Z", NA, "2020-01-01T00:00:00Z"),
    updated_at = c("2026-06-02T00:00:00Z", "2026-09-01T00:00:00Z", "2020-01-02T00:00:00Z"),
    license = c("MIT", "apache-2.0", NA),
    archived = c(FALSE, FALSE, FALSE)
  )
}

decifra_fixture <- function(path) {
  rows <- tibble::tibble(
    id = 1:15, run_id = 1L, document_id = rep(1:3, each = 5),
    variable = rep(c("e_ia", "brasileira", "ptbr", "tipo_artefato", "area_problema"), 3),
    category = c("sim", "sim", "incerto", "aplicacao", "",
                 "sim", "incerto", "sim", "modelo", "",
                 "incerto", "__error__", "incerto", "biblioteca", ""),
    rationale = "r", evidence_span = "trecho",
    selections_json = c(rep("", 4), '[{"label": "saude", "evidence_span": "x"}, {"label": "educacao", "evidence_span": "y"}]',
                        rep("", 4), '[{"label": "cultura_e_linguagem", "evidence_span": "x"}]',
                        rep("", 4), "[]"),
    document_external_id = rep(c("github:1", "huggingface:models:org/modelo", "github:3"), each = 5),
    document_snippet = "..."
  )
  readr::write_csv(rows, path)
  path
}

test_that("TRL separates 1-3 from 4-6, never claims 7-9 and explains itself", {
  trl <- radar_estimar_trl(candidatos_fixture(), referencia = as.Date("2026-09-29"))
  expect_equal(trl$trl_provavel, c("4-6", "4-6", "indeterminado"))
  expect_false(any(trl$trl_provavel == "7-9"))
  expect_equal(trl$ativo, c("sim", "sim", "nao"))
  expect_match(trl$trl_sinais[[1]], "25 estrelas")
  expect_match(trl$trl_sinais[[2]], "avaliação reportados")
  expect_match(trl$trl_sinais[[3]], "sem README")
  # Documentation alone, without use or reported evaluation, stays 1-3.
  quiet <- candidatos_fixture()[1, ]
  quiet$stars <- 0L
  expect_equal(radar_estimar_trl(quiet, as.Date("2026-09-29"))$trl_provavel, "1-3")
  quiet$archived <- TRUE
  quiet$stars <- 500L
  expect_equal(radar_estimar_trl(quiet, as.Date("2026-09-29"))$trl_provavel, "1-3")
})

test_that("Decifra results are joined by external id and failed extractions stay missing", {
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  decifra <- radar_ler_decifra(path)
  expect_true(any(decifra$falhou))
  planilha <- radar_montar_planilha_formulario(
    candidatos_fixture(), decifra, run_id = "teste",
    codebook_path = file.path(repo_root, "config", "codebook.yml"), referencia = as.Date("2026-09-29"))
  expect_equal(planilha$id_solucao, candidatos_fixture()$id)
  expect_equal(planilha$e_ia, c("sim", "sim", "incerto"))
  expect_true(is.na(planilha$brasileira[[3]]))
  expect_equal(planilha$area_problema[[1]], "saude; educacao")
  # Only explicit codebook mappings reach the form; the rest needs a person.
  expect_equal(planilha$form_area[[1]], "Saúde")
  expect_equal(planilha$form_area[[2]], "mapeamento_manual")
  expect_equal(planilha$form_tipo_ativo[[2]], "Modelo de IA treinado")
  expect_equal(planilha$form_aberta, c("Sim, código aberto", "Sim, código aberto", "Não sei"))
  expect_true(all(planilha$form_ja_usado == "nao_verificavel_publicamente"))
  expect_true(all(planilha$estado_revisao == "proposto"))
  expect_equal(unique(planilha$versao_codebook), "0.2.3")
})

test_that("the review workbook hides nothing but keeps the machine answers apart", {
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  corpus <- tibble::tibble(id = candidatos_fixture()$id, text = c("a", "b", "c"), source_urls = "u")
  revisao <- radar_planilha_revisao(corpus, candidatos_fixture(), radar_ler_decifra(path))
  # Two workbooks: the author's has no machine answers at all.
  expect_named(revisao, c("autor", "maquina"))
  expect_named(revisao$autor, c("instrucoes", "codificar"))
  expect_true(all(revisao$autor$codificar$e_ia == ""))
  expect_false(any(grepl("evidencia", names(revisao$autor$codificar))))
  expect_equal(revisao$maquina$maquina$e_ia, c("sim", "sim", "incerto"))
})

test_that("Decifra rows without external ids or duplicated per variable are refused", {
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  rows <- readr::read_csv(path, col_types = readr::cols(.default = "c"))
  rows$document_external_id[[1]] <- NA
  bad <- tempfile(fileext = ".csv")
  readr::write_csv(rows, bad)
  expect_error(radar_ler_decifra(bad), "posição")
  dup <- radar_ler_decifra(path)
  expect_error(radar_decifra_largo(rbind(dup, dup[1, ])), "mais de uma linha")
})

test_that("the candidates table keeps metadata, namespaced ids and README size, never README text", {
  docs <- tibble::tibble(platform = c("github", "huggingface"), id = c("1", "org/m"),
                         kind = c(NA, "models"), name = c("a", "m"), url = c("u1", "u2"),
                         readme = c("texto do README", NA), stars = c(1L, 2L),
                         license = c("MIT", NA), email = c("x", "y"))
  tabela <- radar_tabela_candidatos(docs)
  expect_equal(tabela$id, c("github:1", "huggingface:models:org/m"))
  expect_equal(tabela$readme_chars, c(15L, 0L))
  expect_false(any(c("readme", "email") %in% names(tabela)))
})


test_that("review fixes of PR #32: README only, one row per solution, restricted licences", {
  meta <- "Nome: x\nArtefatos: https://github.com/a/a | https://huggingface.co/org/m\nTópicos/tags: "
  expect_equal(radar_readme_do_documento(c(paste0("Texto do README.\n\n", meta), meta, NA)),
               c("Texto do README.", NA, NA))
  # A solution with two artifacts is one corpus document and one sheet row.
  candidatos <- candidatos_fixture()
  extra <- candidatos[1, ]
  extra$id <- "huggingface:models:a/extra"
  corpus <- tibble::tibble(id = candidatos$id,
                           text = c(paste0(strrep("a", 2000), "\n\n", meta), meta, meta),
                           source_urls = c("https://github.com/a/a | https://huggingface.co/a/extra", "u2", "u3"))
  por_solucao <- radar_candidatos_por_solucao(rbind(candidatos, extra), corpus)
  expect_equal(nrow(por_solucao), 3L)
  expect_match(por_solucao$url[[1]], "huggingface")
  # Metadata text is not documentation: the second document has no README.
  expect_true(is.na(por_solucao$readme[[2]]))
  expect_equal(radar_estimar_trl(por_solucao, as.Date("2026-09-29"))$trl_provavel[[2]], "indeterminado")
  expect_false(any(c("llama2", "llama3", "openrail") %in% RADAR_LICENCAS_ABERTAS))
})

test_that("TRL survives missing dates and does not credit forks with upstream signals", {
  sem_datas <- candidatos_fixture()[c("id", "readme", "stars")]
  expect_equal(radar_estimar_trl(sem_datas, as.Date("2026-09-29"))$ativo, rep(NA_character_, 3))
  estranha <- candidatos_fixture()
  estranha$pushed_at[[1]] <- "ontem"
  estranha$updated_at[[1]] <- "ontem"
  expect_true(is.na(radar_estimar_trl(estranha, as.Date("2026-09-29"))$ativo[[1]]))
  fork <- candidatos_fixture()[1, ]
  fork$fork <- TRUE
  expect_equal(radar_estimar_trl(fork, as.Date("2026-09-29"))$trl_provavel, "1-3")
})

test_that("the inclusion review takes every machine 'sim' plus a reproducible random sample", {
  wide <- tibble::tibble(id = paste0("github:", 1:50),
                         e_ia = c(rep("sim", 10), rep("incerto", 40)),
                         brasileira = c(rep("sim", 6), rep("incerto", 44)),
                         ptbr = c(rep("incerto", 6), rep("sim", 2), rep("incerto", 42)))
  a <- radar_amostra_revisao(wide, n_amostra = 5L)
  expect_equal(sum(a$grupo == "proposto_pela_maquina"), 8L)
  expect_equal(sum(a$grupo == "amostra_do_resto"), 5L)
  expect_equal(a, radar_amostra_revisao(wide, n_amostra = 5L))
  # Shuffled: the machine's proposals are not simply listed first.
  expect_false(all(a$grupo[1:8] == "proposto_pela_maquina"))
})

test_that("evidence quotations are short single lines and the fichas sheet has blank review columns", {
  expect_equal(radar_trecho_curto(c("a\n  b", NA, strrep("x", 400)), 10L),
               c("a b", NA, paste0(strrep("x", 9), "…")))
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  # Real candidates tables have no README text: TRL must come from the corpus.
  sem_readme <- candidatos_fixture()
  sem_readme$readme <- NULL
  corpus <- tibble::tibble(id = sem_readme$id,
                           text = paste0(c(strrep("Instalação e exemplo. ", 100), "x", "y"),
                                         "

Nome: a
Artefatos: u
Tópicos/tags: "),
                           source_urls = "u")
  fichas <- radar_planilha_fichas(c("github:1"), radar_ler_decifra(path), sem_readme, corpus,
                                  resumos = c(`github:1` = "Ajuda alguém."), referencia = as.Date("2026-09-29"))
  expect_equal(fichas$trl_proposto, "4-6")
  expect_error(radar_planilha_fichas(c("github:1"), radar_ler_decifra(path), sem_readme, corpus,
                                     resumos = c(`github:1` = strrep("copiado ", 80))), "reescreva")
  expect_error(radar_trecho_curto("abc", 0L), "pelo menos 2")
  expect_equal(fichas$tipo_proposto, "aplicacao")
  expect_equal(fichas$resumo_proposto, "Ajuda alguém.")
  expect_true(all(fichas[c("tipo_revisao", "area_revisao", "trl_revisao", "resumo_revisao")] == ""))
  expect_lte(max(nchar(stats::na.omit(unlist(fichas[grepl("trecho", names(fichas))])))), 300L)
})


test_that("the review workbook follows the sample order and never shows the group", {
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  corpus <- tibble::tibble(id = candidatos_fixture()$id, text = c("a", "b", "c"), source_urls = "u")
  ordem <- rev(candidatos_fixture()$id)[1:2]
  revisao <- radar_planilha_revisao(corpus, candidatos_fixture(), radar_ler_decifra(path), ids = ordem)
  expect_equal(revisao$autor$codificar$id, ordem)
  expect_false("grupo" %in% names(revisao$autor$codificar))
  expect_error(radar_planilha_revisao(corpus, candidatos_fixture(), radar_ler_decifra(path), ids = "github:999"),
               "fora do corpus")
})
