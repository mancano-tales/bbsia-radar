test_that("pilot declaration is bounded and uses only listed seeds", {
  path <- file.path(repo_root, "config", "rodadas", "2026-09-29_piloto.yml")
  run <- radar_ler_rodada(path)
  expect_equal(run$run_id, "2026-09-29_piloto")
  expect_equal(run$max_tentativas, 150L)
  expect_equal(run$max_documentos, 40L)
  expect_equal(run$github$topicos, c("portuguese-nlp", "brazilian-portuguese", "pt-br"))
  expect_equal(length(run$huggingface$contas), 6L)
  for (field in c("max_tentativas", "max_documentos")) {
    altered <- readr::read_file(path)
    altered <- sub(paste0(field, ": [0-9]+"),
                   paste0(field, ": ", if (field == "max_tentativas") 151L else 41L), altered)
    fixture <- tempfile(fileext = ".yml")
    writeLines(altered, fixture, useBytes = TRUE)
    expect_error(radar_ler_rodada(fixture), if (field == "max_tentativas") "150" else "40")
  }
})

test_that("proportional selection keeps one per platform and prioritizes seed and description", {
  candidates <- tibble::tibble(
    platform = c(rep("github", 7), rep("huggingface", 2), "gitlab"),
    url = paste0("https://example.test/", seq_len(10)),
    description = c(rep(NA_character_, 4), "descrição", NA_character_, NA_character_,
                    "modelo", NA_character_, "projeto")
  )
  chosen <- selecionar_enriquecimento_rodada(candidates, 5L,
                                              priority_urls = candidates$url[[7]])
  expect_equal(as.integer(table(chosen$platform)[c("github", "huggingface", "gitlab")]),
               c(3L, 1L, 1L))
  expect_true(candidates$url[[7]] %in% chosen$url)
  expect_true(candidates$url[[5]] %in% chosen$url)
  expect_identical(chosen, selecionar_enriquecimento_rodada(candidates[10:1, ], 5L,
                                                            priority_urls = candidates$url[[7]]))
})

test_that("artifact IDs are unique and Decifra text is cut at 24000 characters", {
  gh <- tibble::tibble(platform = "github", id = "123", solution_id = "shared",
                       name = "A", description = "descrição", url = "https://github.com/a/b",
                       owner = "a", topics = list("pt-br"), readme = strrep("x", 25000))
  hf <- tibble::tibble(platform = "huggingface", id = "a/model", kind = "models",
                       solution_id = "shared", name = "M", description = "modelo",
                       url = "https://huggingface.co/a/model", owner = "a",
                       topics = list("pt-br"), readme = "Card")
  corpus <- montar_corpus(gh, hf, artifact_ids = TRUE, max_chars = 24000L)
  expect_equal(corpus$id, "github:123")
  expect_false(anyDuplicated(corpus$id) > 0L)
  expect_equal(nchar(corpus$text), 24000L)
  expect_true(corpus$text_truncated)
  expect_gt(corpus$text_length_original, 24000L)
  declared <- radar_ler_rodada(file.path(repo_root, "config", "rodadas", "2026-09-29_piloto.yml"))
  manifest <- radar_manifesto_piloto(declared, radar_novo_orcamento(150L, 40L),
                                    list(github = 1L), corpus)
  expect_equal(manifest$totais$documentos_cortados, 1L)
})

test_that("offline pilot records absent HF accounts, statuses, counts and corpus externally", {
  root <- tempfile("radar-pilot-"); dir.create(root)
  seed <- file.path(repo_root, "config", "rodadas", "2026-09-29_piloto.yml")
  calls <- list()
  gh_repo <- function(full_name, id) list(
    id = id, full_name = full_name, name = sub(".*/", "", full_name),
    html_url = paste0("https://github.com/", full_name), private = FALSE,
    description = "Modelo em português", owner = list(login = sub("/.*", "", full_name)),
    topics = list("pt-br"), stargazers_count = 1L
  )
  gh <- function(path, query) {
    calls[[length(calls) + 1L]] <<- list(path = path, query = query)
    if (grepl("/readme$", path)) return(list(
      sha = strrep("b", 40), encoding = "base64",
      content = jsonlite::base64_enc(charToRaw("Documentação pública"))))
    if (grepl("^GET /repos/", path)) {
      name <- sub("^GET /repos/", "", path)
      return(gh_repo(name, if (grepl("antrologos", name)) 11L else 12L))
    }
    if (grepl("^GET /users/neuralmind-ai/repos$", path))
      return(list(gh_repo("neuralmind-ai/portuguese-bert", 12L)))
    if (grepl("^GET /users/", path)) return(list())
    list(items = list(), total_count = 0L, incomplete_results = FALSE)
  }
  hf <- function(kind, query, file = NULL) {
    if (!is.null(file)) return("Card público")
    if (grepl("^users/", kind))
      return(list(.radar_http_status = 404L, .radar_http_body = list(message = "not found")))
    if (identical(query$author, "neuralmind")) return(list(items = list(
      list(id = "neuralmind/bert-base-portuguese-cased", sha = strrep("a", 40),
           description = "Modelo brasileiro"))))
    list(items = list())
  }
  gl <- function(method, path, query) list(status = 200L, body = list(), headers = list())
  result <- radar_executar_rodada(seed, root, gh, hf, gl)
  expect_equal(result$manifesto$contas_hf$nicholasKluge, "inexistente")
  expect_equal(result$manifesto$totais$github, 2L)
  expect_equal(result$manifesto$totais$huggingface, 1L)
  expect_equal(result$manifesto$status_http[["huggingface:404"]], 5L)
  expect_equal(result$manifesto$paginas_lidas, 14L)
  expect_equal(nrow(result$corpus), 2L)
  expect_true(all(grepl("^(github|huggingface):", result$corpus$id)))
  expect_true(file.exists(result$manifest_path))
  expect_true(file.exists(result$corpus_path))
  expect_equal(nrow(readr::read_csv(result$corpus_path, show_col_types = FALSE)), 2L)
  expect_true(all(vapply(calls[grepl("/search/repositories", vapply(calls, `[[`, character(1), "path"))],
                         function(call) grepl("^topic:", call$query$q), logical(1))))
  expect_error(radar_executar_rodada(seed, root, gh, hf, gl), "Manifesto")
})
