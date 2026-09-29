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
  expect_equal(codebook$versao, "0.2.0")
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
})
