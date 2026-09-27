test_that("GitHub normalizer allow-lists fields and never returns email", {
  path <- testthat::test_path("..", "fixtures", "github_search.json")
  fixture <- jsonlite::read_json(path, simplifyVector = FALSE)
  repos <- bind_github_items(list(fixture$items))
  expect_equal(repos$full_name, "antrologos/Transcritorio")
  expect_false("email" %in% names(repos))
  expect_false(any(grepl("must-not-be-read", unlist(repos), fixed = TRUE)))
})

test_that("GitHub search recursively splits an overfull date window", {
  calls <- character()
  fake <- function(path, query) {
    calls <<- c(calls, paste(query$q, query$page, sep = " #"))
    if (grepl("2020-01-01..2020-12-31", query$q, fixed = TRUE)) {
      list(total_count = 1200L, items = list())
    } else {
      list(total_count = 1L, items = list(list(
        id = 1L, full_name = "org/repo", name = "repo", html_url = "https://github.com/org/repo",
        owner = list(login = "org"), description = "fixture", stargazers_count = 1L
      )))
    }
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  output <- github_search_window("Brazil", "2020-01-01", "2020-12-31", root, fake)
  expect_equal(nrow(output), 2L)
  expect_true(any(grepl("2020-01-01..2020-12-31", calls, fixed = TRUE)))
})

test_that("GitHub README content is decoded from the API and cached", {
  root <- tempfile("radar-cache-"); dir.create(root)
  fake <- function(path, query) list(content = jsonlite::base64_enc(charToRaw("Título pt-BR")))
  input <- tibble::tibble(full_name = "org/repo", url = "https://github.com/org/repo")
  output <- coletar_readme_github(input, root = root, request_fn = fake)
  expect_match(output$readme, "pt-BR")
  expect_true(length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$")) == 1L)
})

test_that("GitHub collector combines fixture searches and curated accounts", {
  calls <- character()
  fake <- function(path, query) {
    calls <<- c(calls, path)
    repo <- list(id = 101L, name = "fixture", full_name = "example/fixture",
                 html_url = "https://github.com/example/fixture", description = "fixture only",
                 stargazers_count = 2L, owner = list(login = "example"))
    if (grepl("search/repositories", path, fixed = TRUE)) list(total_count = 1L, items = list(repo)) else list(repo)
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  output <- coletar_github(seed_path, root, request_fn = fake, since = "2020-01-01", until = "2020-12-31")
  expect_true("GET /search/repositories" %in% calls)
  expect_true(any(grepl("/orgs/example/repos", calls, fixed = TRUE)))
  expect_equal(output$solution_id, "fixture-solution")
})

test_that("HF normalizer omits private-profile fields", {
  path <- testthat::test_path("..", "fixtures", "hf_models.json")
  fixture <- jsonlite::read_json(path, simplifyVector = FALSE)
  models <- hf_normalize_items(fixture, "models")
  expect_equal(models$id, "neuralmind/bert-base-portuguese-cased")
  expect_equal(models$url, "https://huggingface.co/neuralmind/bert-base-portuguese-cased")
  expect_false("email" %in% names(models))
  expect_false(any(grepl("must-not-be-read", unlist(models), fixed = TRUE)))
})

test_that("HF pagination stops when no next link exists", {
  requests <- 0L
  fake <- function(kind, query) {
    requests <<- requests + 1L
    jsonlite::read_json(testthat::test_path("..", "fixtures", "hf_models.json"), simplifyVector = FALSE)
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  value <- hf_collect_query("models", list(author = "neuralmind", limit = 100), root, fake)
  expect_length(value, 1L)
  expect_equal(requests, 1L)
})

test_that("HF pagination follows Link headers and fixture next-page wrappers", {
  link <- '<https://huggingface.co/api/models?cursor=abc>; rel="next", <https://huggingface.co/api/models>; rel="first"'
  expect_equal(hf_link_next(link), "https://huggingface.co/api/models?cursor=abc")
  page <- 0L
  fake <- function(kind, query) {
    page <<- page + 1L
    if (page == 1L) list(items = list(list(id = "org/first")), "next" = "fixture-page-2") else list(items = list(list(id = "org/second")))
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  output <- hf_collect_query("models", list(author = "org"), root, fake)
  expect_equal(purrr::map_chr(output, "id"), c("org/first", "org/second"))
})

test_that("HF collector enumerates accounts and keeps a known-positive model", {
  calls <- character()
  fake <- function(kind, query) {
    calls <<- c(calls, kind)
    if (identical(kind, "models/example/fixture-model")) {
      list(id = "example/fixture-model", likes = 1L, tags = character())
    } else list()
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  output <- coletar_hf(seed_path, root, request_fn = fake, max_pages = 1L)
  expect_true("models" %in% calls)
  expect_equal(output$id, "example/fixture-model")
  expect_equal(output$solution_id, "fixture-solution")
})
