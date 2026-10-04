test_that("corpus emits one Decifra document per solution and plain metadata lines", {
  gh <- tibble::tibble(platform = "github", solution_id = "bertimbau", name = "BERTimbau",
                       description = "Modelo pt-BR", url = "https://github.com/org/bertimbau",
                       owner = "org", updated_at = "2026-09-01", topics = list("pt-br"),
                       readme = "README cita avaliação no Brasil.")
  hf <- tibble::tibble(platform = "huggingface", solution_id = "bertimbau", name = "bert-base",
                       description = "Card", url = "https://huggingface.co/org/bert-base",
                       owner = "org", updated_at = "2026-09-02", topics = list("pt"),
                       readme = "Model card cita treinamento.")
  corpus <- montar_corpus(gh, hf)
  expect_equal(nrow(corpus), 1L)
  expect_match(corpus$text[[1]], "README cita avaliação")
  expect_match(corpus$text[[1]], "org")
  expect_match(corpus$text[[1]], "Artefatos:")
})

test_that("curated seed identity joins the seeded GitHub and HF artifacts", {
  artifacts <- tibble::tibble(url = c(
    "https://github.com/neuralmind-ai/portuguese-bert",
    "https://huggingface.co/neuralmind/bert-base-portuguese-cased"
  ))
  seeds <- yaml::yaml.load(readr::read_file(file.path(repo_root, "config", "seeds.yml"),
                                           locale = readr::locale(encoding = "UTF-8")))
  mapped <- aplicar_ids_sementes(artifacts, seeds)
  expect_equal(mapped$solution_id, c("neuralmind-bertimbau", "neuralmind-bertimbau"))
})

test_that("corpus export defaults to the external data root", {
  root <- tempfile("radar-export-"); dir.create(root)
  corpus <- tibble::tibble(id = "one", text = "A citable document.")
  path <- salvar_corpus_decifra(corpus, root = root)
  expect_true(file.exists(path))
  expect_true(startsWith(normalizePath(path, winslash = "/"), normalizePath(root, winslash = "/")))
  expect_equal(readr::read_csv(path, show_col_types = FALSE)$id, "one")
})

test_that("codebook converter emits the approved Decifra variables and R1.1 area bounds", {
  converted <- codebook_para_decifra(file.path(repo_root, "config", "codebook.yml"))
  names <- purrr::map_chr(converted$variables, "name")
  expect_setequal(names, c("e_ia", "brasileira", "ptbr", "tipo_artefato", "area_problema"))
  area <- converted$variables[[match("area_problema", names)]]
  expect_true(area$multi_label)
  expect_equal(area$max_labels, 2L)
  expect_equal(area$evidence_granularity, "per_label")
  single <- converted$variables[[match("e_ia", names)]]
  expect_false("min_labels" %in% names(single))
  expect_false("max_labels" %in% names(single))
  expect_false("evidence_granularity" %in% names(single))
  expect_false("interesse_publico" %in% names)
})

test_that("generated YAML round-trips without changing the source codebook", {
  source_path <- file.path(repo_root, "config", "codebook.yml")
  before <- readLines(source_path, warn = FALSE)
  target <- tempfile(fileext = ".yml")
  codebook_para_decifra(codebook_path = source_path, output_path = target)
  generated <- yaml::read_yaml(target)
  expect_true(all(c("concept", "description", "variables") %in% names(generated)))
  expect_identical(readLines(source_path, warn = FALSE), before)
})

test_that("BBSIA form mapping uses observed options and leaves ambiguous categories manual", {
  codebook <- yaml::yaml.load(readr::read_file(file.path(repo_root, "config", "codebook.yml"),
                                                 locale = readr::locale(encoding = "UTF-8")))
  form <- yaml::yaml.load(readr::read_file(file.path(repo_root, "config", "formulario_bbsia.yml"),
                                             locale = readr::locale(encoding = "UTF-8")))
  expect_equal(codebook$versao, "0.2.3")
  expect_equal(form$fonte, "https://bancobrasileiro.ia.br/contribuir")
  for (entry in list(list(internal = codebook$tipo_artefato, form = form$campos$tipo_ativo),
                     list(internal = codebook$area_problema, form = form$campos$area))) {
    mapped <- unlist(entry$internal$mapeamento_formulario, use.names = FALSE)
    manual <- unlist(entry$internal$mapeamento_manual, use.names = FALSE)
    internal <- if (identical(entry$internal, codebook$tipo_artefato)) {
      names(entry$internal$valores)
    } else {
      unlist(entry$internal$valores, use.names = FALSE)
    }
    expect_true(all(mapped %in% unlist(entry$form$opcoes, use.names = FALSE)))
    expect_setequal(c(names(entry$internal$mapeamento_formulario), manual), internal)
    expect_length(intersect(names(entry$internal$mapeamento_formulario), manual), 0L)
  }
  expect_true(grepl("incerto.*sem sinais", codebook$vinculo$brasileira$regra_de_decisao))
  expect_true(grepl("ausência de sinais", codebook$vinculo$ptbr$regra_de_decisao))
  expect_true(all(c("meio_ambiente_e_agro", "gestao_publica") %in% codebook$area_problema$mapeamento_manual))
  expect_match(codebook$e_ia$regra_de_decisao, "silêncio.*incerto")
  expect_match(codebook$e_ia$regra_de_decisao, "`nao` exige evidência positiva")
})

test_that("Decifra definitions retain evidence rules and examples stay in their category", {
  converted <- codebook_para_decifra(file.path(repo_root, "config", "codebook.yml"))
  vars <- stats::setNames(converted$variables, purrr::map_chr(converted$variables, "name"))
  for (name in c("brasileira", "ptbr")) {
    cats <- stats::setNames(vars[[name]]$categories, purrr::map_chr(vars[[name]]$categories, "label"))
    expect_length(cats$nao$positive_examples, 0L)
    expect_length(cats$sim$negative_examples, 0L)
    expect_length(cats$incerto$positive_examples, 0L)
    expect_match(cats$sim$definition, "Sinais fortes")
    expect_match(cats$sim$definition, "Sinais m")
    expect_match(cats$sim$definition, "Sinais fracos")
  }
  ia <- stats::setNames(vars$e_ia$categories, purrr::map_chr(vars$e_ia$categories, "label"))
  expect_match(ia$sim$definition, "Inclui")
  expect_match(ia$nao$definition, "Exclui")
  expect_match(ia$incerto$boundary_notes, "silêncio.*incerto")
})

test_that("acceptance cases follow the codebook decision rule, case by case", {
  fixtures <- yaml::yaml.load(readr::read_file(
    file.path(repo_root, "tests", "fixtures", "codebook_aceitacao.yml"),
    locale = readr::locale(encoding = "UTF-8")))
  ids <- purrr::map_chr(fixtures$casos, "id")
  expect_false(anyDuplicated(ids) > 0)
  # Cases the author asked for (2026-09-29): one and two medium signals,
  # European Portuguese only, generic multilingual models.
  expect_true(all(c("sem_evidencia", "conflitante", "multirrotulo",
                    "brasileira_um_sinal_medio", "brasileira_dois_sinais_medios",
                    "so_pt_pt", "multilingue_generico_documentado",
                    "multilingue_so_tag") %in% ids))
  for (caso in fixtures$casos) {
    decided <- radar_decidir_caso(caso$sinais %||% list())
    expected <- unlist(caso$esperado[c("e_ia", "brasileira", "ptbr")])
    expect_equal(decided, expected, info = caso$id)
    expect_lte(length(caso$esperado$area_problema), 2L)
  }
})

test_that("the executable rule matches the thresholds written in the codebook", {
  codebook <- yaml::yaml.load(readr::read_file(file.path(repo_root, "config", "codebook.yml"),
                                               locale = readr::locale(encoding = "UTF-8")))
  for (flag in c("brasileira", "ptbr")) {
    rule <- gsub("[[:space:]]+", " ", codebook$vinculo[[flag]]$regra_de_decisao)
    expect_match(rule, "`sim` com 1 sinal forte, ou 2 médios", info = flag)
  }
  expect_match(codebook$e_ia$regra_de_decisao, "silêncio da documentação leva a `incerto`")
  expect_equal(radar_decidir_marcacao(medios = 1L), "incerto")
  expect_equal(radar_decidir_marcacao(medios = 2L), "sim")
  expect_equal(radar_decidir_marcacao(fracos = 5L), "incerto")
  expect_equal(radar_decidir_marcacao(), "incerto")
  expect_equal(radar_decidir_marcacao(negativa = TRUE), "nao")
  expect_equal(radar_decidir_marcacao(fortes = 1L, negativa = TRUE), "incerto")
  expect_error(radar_decidir_marcacao(medios = -1L))
  expect_error(radar_decidir_marcacao(negativa = NA))
})

test_that("e_ia needs model evidence, and medium signals against contrary evidence conflict", {
  # Review of PR #31: e_ia has no signal scale; two medium signals are not
  # citable evidence of a learned model.
  expect_equal(radar_decidir_marcacao(medios = 2L, regra = "e_ia"), "incerto")
  expect_equal(radar_decidir_marcacao(fortes = 1L, regra = "e_ia"), "sim")
  expect_equal(radar_decidir_marcacao(negativa = TRUE, regra = "e_ia"), "nao")
  expect_equal(radar_decidir_marcacao(medios = 1L, negativa = TRUE), "incerto")
  expect_equal(radar_decidir_marcacao(fracos = 1L, negativa = TRUE), "nao")
  expect_error(radar_decidir_marcacao(regra = "outra"))
})
