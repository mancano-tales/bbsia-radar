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
  expect_equal(unique(planilha$versao_codebook), "0.2.2")
})

test_that("the review workbook hides nothing but keeps the machine answers apart", {
  path <- decifra_fixture(tempfile(fileext = ".csv"))
  corpus <- tibble::tibble(id = candidatos_fixture()$id, text = c("a", "b", "c"), source_urls = "u")
  revisao <- radar_planilha_revisao(corpus, candidatos_fixture(), radar_ler_decifra(path))
  expect_named(revisao, c("instrucoes", "codificar", "maquina"))
  expect_true(all(revisao$codificar$e_ia == ""))
  expect_false(any(c("e_ia", "brasileira", "ptbr") %in% names(revisao$codificar)[1:4]))
  expect_equal(revisao$maquina$e_ia, c("sim", "sim", "incerto"))
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
