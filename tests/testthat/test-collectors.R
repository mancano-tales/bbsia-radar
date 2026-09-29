test_that("request budget enforces the hard exploratory ceilings", {
  expect_equal(radar_novo_orcamento(max_tentativas = 25L)$max_tentativas, 25L)
  expect_error(radar_novo_orcamento(max_tentativas = 26L), "1 e 25")
  expect_error(radar_novo_orcamento(max_documentos = 11L), "0 e 10")

  budget <- radar_novo_orcamento(max_tentativas = 2L)
  radar_reservar_requisicao(budget, "github", "search one")
  radar_reservar_requisicao(budget, "huggingface", "models")
  expect_error(radar_reservar_requisicao(budget, "github", "search two"), "esgotado")
})

test_that("cache root must exist, be writable, and stay outside the checkout", {
  root <- tempfile("radar-cache-")
  dir.create(root)
  expect_equal(radar_validate_cache_root(root), normalizePath(root, winslash = "/"))
  expect_error(radar_validate_cache_root(getwd()), "dentro do checkout")
  expect_error(radar_validate_cache_root(file.path(root, "missing")), "precisa existir")
})

test_that("GitHub normalizer allow-lists fields and never returns email", {
  path <- testthat::test_path("..", "fixtures", "github_search.json")
  fixture <- jsonlite::read_json(path, simplifyVector = FALSE)
  repos <- bind_github_items(list(fixture$items))
  expect_equal(repos$full_name, "antrologos/Transcritorio")
  expect_false("email" %in% names(repos))
  expect_false(any(grepl("must-not-be-read", unlist(repos), fixed = TRUE)))
})

test_that("GitHub Search uses one bounded page and records partial coverage", {
  calls <- list()
  fake <- function(path, query) {
    calls[[length(calls) + 1L]] <<- list(path = path, query = query)
    list(total_count = 1200L, incomplete_results = FALSE, items = list(list(
      id = 1L, full_name = "org/repo", name = "repo", html_url = "https://github.com/org/repo",
      owner = list(login = "org"), description = "fixture", stargazers_count = 1L
    )))
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  output <- github_search_window("radar-fixture-seed", "2020-01-01", "2020-12-31", root, fake, budget)
  summary <- attr(output, "search_summary")
  expect_equal(length(calls), 1L)
  expect_equal(calls[[1]]$query$page, 1)
  expect_equal(calls[[1]]$query$per_page, 100)
  expect_equal(calls[[1]]$query$sort, "updated")
  expect_match(calls[[1]]$query$q, "is:public")
  expect_true(summary$partial)
  expect_equal(summary$total_count, 1200L)
  expect_equal(budget$tentativas_reservadas, 1L)
})

test_that("GitHub rejects a private search result before it reaches the cache", {
  root <- tempfile("radar-cache-"); dir.create(root)
  fake_private <- function(path, query) list(
    total_count = 1L,
    incomplete_results = FALSE,
    items = list(list(id = 7L, full_name = "owner/private", private = TRUE))
  )
  expect_error(github_search_window(
    "radar-fixture-seed", "2020-01-01", "2020-12-31", root,
    request_fn = fake_private, budget = radar_novo_orcamento()
  ), "privado")
  expect_length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$"), 0L)
})

test_that("curated global list contributes only its Brazilian GitHub gold seeds", {
  fixture <- testthat::test_path("..", "fixtures", "seeds_awesome_brazil.yml")
  seeds <- yaml::yaml.load(readr::read_file(fixture))
  candidates <- github_sementes_lista_brasileiras(
    seeds, "awesome-open-source-research-tools"
  )
  expect_equal(
    candidates$solution_id,
    c("antrologos-transcritorio", "lfnovo-open-notebook", "luizpf42-qualilab")
  )
  expect_false("global-tool" %in% candidates$solution_id)
  expect_error(github_sementes_lista_brasileiras(seeds, "unknown-list"), "config/seeds.yml")
})

test_that("author-approved GitHub query terms include solution names and repository slugs", {
  fixture <- testthat::test_path("..", "..", "config", "seeds.yml")
  seeds <- yaml::yaml.load(readr::read_file(fixture))
  expect_equal(
    github_validar_termos(c("Transcritorio", "BERTimbau"), seeds),
    c("Transcritorio", "BERTimbau")
  )
})

test_that("curated-list scope and request budget are validated before GitHub calls", {
  root <- tempfile("radar-cache-"); dir.create(root)
  fixture <- testthat::test_path("..", "fixtures", "seeds_awesome_brazil.yml")
  calls <- 0L
  fake <- function(path, query) {
    calls <<- calls + 1L
    list(total_count = 0L, incomplete_results = FALSE, items = list())
  }
  expect_error(coletar_github(
    fixture, root, request_fn = fake, search_terms = "Transcritorio",
    include_curated_list = "unknown-list", budget = radar_novo_orcamento()
  ), "config/seeds.yml")
  expect_equal(calls, 0L)

  expect_error(coletar_github(
    fixture, root, request_fn = fake, search_terms = "Transcritorio",
    include_curated_list = "awesome-open-source-research-tools",
    budget = radar_novo_orcamento(max_tentativas = 3L)
  ), "comporta")
  expect_equal(calls, 0L)
})

test_that("curated-list GitHub metadata uses official endpoint, cache and field allow-list", {
  root <- tempfile("radar-cache-"); dir.create(root)
  fixture <- testthat::test_path("..", "fixtures", "seeds_awesome_brazil.yml")
  seed_urls <- c(
    "https://github.com/antrologos/Transcritorio",
    "https://github.com/lfnovo/open-notebook",
    "https://github.com/LuizPF42/QualiLab"
  )
  paths <- character()
  fake <- function(path, query) {
    paths <<- c(paths, path)
    if (path == "GET /search/repositories") {
      return(list(total_count = 0L, incomplete_results = FALSE, items = list()))
    }
    index <- match(tolower(sub("^GET /repos/", "", path)), tolower(sub("^https://github.com/", "", seed_urls)))
    repo <- sub("^https://github.com/", "", seed_urls[[index]])
    list(
      id = as.integer(index), full_name = repo, name = sub(".*/", "", repo),
      html_url = seed_urls[[index]], private = FALSE,
      owner = list(login = sub("/.*", "", repo)), description = "fixture contato test@example.org",
      stargazers_count = 3L, email = "must-not-be-read@example.org"
    )
  }
  output <- coletar_github(
    fixture, root, request_fn = fake, search_terms = "Transcritorio",
    include_curated_list = "awesome-open-source-research-tools",
    budget = radar_novo_orcamento(), since = "2020-01-01", until = "2020-12-31"
  )
  expect_equal(nrow(output), 3L)
  expect_equal(sort(output$solution_id), sort(c(
    "antrologos-transcritorio", "lfnovo-open-notebook", "luizpf42-qualilab"
  )))
  expect_true(all(grepl("tag brazil", output$seed_source, fixed = TRUE)))
  expect_false("email" %in% names(output))
  expect_false(any(grepl("@", unlist(output), fixed = TRUE)))
  expect_equal(length(paths), 4L)
  expect_true(all(grepl("^GET /repos/", paths[-1])))

  # Cache hits satisfy a repeat run without calling the fake transport again.
  calls_after_first_run <- length(paths)
  cached <- coletar_github(
    fixture, root, request_fn = fake, search_terms = "Transcritorio",
    include_curated_list = "awesome-open-source-research-tools",
    budget = radar_novo_orcamento(), since = "2020-01-01", until = "2020-12-31"
  )
  expect_equal(length(paths), calls_after_first_run)
  expect_equal(cached$solution_id, output$solution_id)
})

test_that("GitHub refuses curated metadata without explicit public visibility before caching", {
  root <- tempfile("radar-cache-"); dir.create(root)
  fixture <- testthat::test_path("..", "fixtures", "seeds_awesome_brazil.yml")
  calls <- character()
  expect_error(coletar_github(
    fixture, root, request_fn = function(path, query) {
      calls <<- c(calls, path)
      if (path == "GET /search/repositories") {
        return(list(total_count = 0L, incomplete_results = FALSE, items = list()))
      }
      list(full_name = "antrologos/Transcritorio", private = TRUE)
    },
    search_terms = "Transcritorio",
    include_curated_list = "awesome-open-source-research-tools",
    budget = radar_novo_orcamento()
  ), "cacheada")
  cache_files <- list.files(
    file.path(root, "bbsia-radar", "api"), pattern = "json$", full.names = TRUE
  )
  expect_length(cache_files, 1L)
  expect_match(calls[[2]], "^GET /repos/")

  missing_visibility <- function(path, query) {
    calls <<- c(calls, path)
    if (path == "GET /search/repositories") {
      return(list(total_count = 0L, incomplete_results = FALSE, items = list()))
    }
    list(full_name = "antrologos/Transcritorio")
  }
  expect_error(coletar_github(
    fixture, root, request_fn = missing_visibility, search_terms = "Transcritorio",
    include_curated_list = "awesome-open-source-research-tools",
    budget = radar_novo_orcamento()
  ), "cacheada")
  cache_files <- list.files(
    file.path(root, "bbsia-radar", "api"), pattern = "json$", full.names = TRUE
  )
  expect_length(cache_files, 1L)
})

test_that("GitHub public requests never inherit a local personal access token", {
  previous <- Sys.getenv("GITHUB_PAT", unset = NA_character_)
  on.exit(if (is.na(previous)) Sys.unsetenv("GITHUB_PAT") else Sys.setenv(GITHUB_PAT = previous))
  Sys.setenv(GITHUB_PAT = "test-token-must-not-be-sent")
  request <- github_http_request("GET /repos/example/model/readme")
  headers <- names(request$headers)
  expect_false(any(tolower(headers) == "authorization"))
})

test_that("GitHub collector requires at most two exact seed terms and never crawls accounts", {
  calls <- character()
  fake <- function(path, query) {
    calls <<- c(calls, path)
    repo <- list(id = 101L, name = "fixture", full_name = "example/fixture",
                 html_url = "https://github.com/example/fixture", description = "fixture only",
                 stargazers_count = 2L, owner = list(login = "example"))
    list(total_count = 1L, incomplete_results = FALSE, items = list(repo))
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  budget <- radar_novo_orcamento()
  output <- coletar_github(
    seed_path, root, request_fn = fake, search_terms = "radar-fixture-seed", budget = budget,
    since = "2020-01-01", until = "2020-12-31"
  )
  expect_equal(calls, "GET /search/repositories")
  expect_equal(output$solution_id, "fixture-solution")
  expect_equal(nrow(attr(output, "radar_metadata")$searches), 1L)
  expect_error(coletar_github(
    seed_path, root, request_fn = fake,
    search_terms = c("radar-fixture-seed", "Fixture", "third"), budget = radar_novo_orcamento()
  ), "termos distintos")
  expect_error(coletar_github(
    seed_path, root, request_fn = fake, search_terms = "not-a-seed", budget = radar_novo_orcamento()
  ), "corresponder")
  expect_error(coletar_github(
    seed_path, getwd(), request_fn = fake, search_terms = "radar-fixture-seed",
    budget = radar_novo_orcamento()
  ), "dentro do checkout")
  expect_length(calls, 1L)
})

test_that("empty discovery responses return typed empty tables without follow-up calls", {
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  github_budget <- radar_novo_orcamento()
  github <- coletar_github(
    seed_path, root, request_fn = function(path, query) {
      list(total_count = 0L, incomplete_results = FALSE, items = list())
    },
    search_terms = "radar-fixture-seed", budget = github_budget
  )
  expect_equal(nrow(github), 0L)
  expect_true("solution_id" %in% names(github))

  hf_budget <- radar_novo_orcamento()
  hf <- coletar_hf(
    seed_path, root, request_fn = function(kind, query) list(),
    account = "example", budget = hf_budget
  )
  expect_equal(nrow(hf), 0L)
  expect_true("solution_id" %in% names(hf))
  expect_match(attr(hf, "radar_metadata")$account_check, "lista veio vazia")
})

test_that("GitHub README content is decoded and each attempted document consumes budget", {
  root <- tempfile("radar-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  fake <- function(path, query) list(
    content = jsonlite::base64_enc(charToRaw("Título pt-BR")), sha = strrep("b", 40))
  input <- tibble::tibble(full_name = "org/repo", url = "https://github.com/org/repo")
  output <- coletar_readme_github(input, root = root, request_fn = fake, budget = budget)
  expect_match(output$readme, "pt-BR")
  expect_match(output$content_hash, paste0("^github:", strrep("b", 40), ":"))
  expect_equal(budget$tentativas_reservadas, 1L)
  expect_true(length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$")) == 1L)
  expect_error(coletar_readme_github(
    tibble::tibble(full_name = paste0("org/repo", 1:11), url = paste0("https://github.com/org/repo", 1:11)),
    root = root, request_fn = fake, budget = radar_novo_orcamento()
  ), "dez documentos")
})

test_that("Hugging Face README uses a commit SHA and hashes the read text", {
  root <- tempfile("radar-hf-hash-"); dir.create(root)
  input <- tibble::tibble(id = "org/model", kind = "models", sha = strrep("a", 40))
  output <- coletar_readme_hf(input, root, function(repo_id, kind, file) "Model card",
                              radar_novo_orcamento())
  expect_match(output$content_hash[[1]], paste0("^huggingface:", strrep("a", 40), ":"))
  expect_equal(output$readme_status[[1]], "read")
  input$sha <- NA_character_
  no_sha <- coletar_readme_hf(input, root, function(repo_id, kind, file) "Model card",
                               radar_novo_orcamento())
  expect_true(is.na(no_sha$readme[[1]]))
  expect_equal(no_sha$readme_status[[1]], "sem_sha")
  input$sha <- "main"
  expect_error(coletar_readme_hf(input, root, function(repo_id, kind, file) "Model card",
                                 radar_novo_orcamento()))
})

test_that("HTTP errors consume budget once and 404 remains a missing README", {
  root <- tempfile("radar-cache-"); dir.create(root)
  budget_404 <- radar_novo_orcamento()
  calls_404 <- 0L
  fake_404 <- function(path, query) {
    calls_404 <<- calls_404 + 1L
    list(.radar_http_status = 404L, .radar_http_body = list(message = "Not Found"))
  }
  missing <- coletar_readme_github(
    tibble::tibble(full_name = "org/no-readme", url = "https://github.com/org/no-readme"),
    root = root, request_fn = fake_404, budget = budget_404
  )
  expect_true(is.na(missing$readme))
  expect_equal(budget_404$tentativas_reservadas, 1L)
  cached_404_budget <- radar_novo_orcamento()
  cached_missing <- coletar_readme_github(
    tibble::tibble(full_name = "org/no-readme", url = "https://github.com/org/no-readme"),
    root = root, request_fn = fake_404, budget = cached_404_budget
  )
  expect_true(is.na(cached_missing$readme))
  expect_equal(calls_404, 1L)
  expect_equal(cached_404_budget$tentativas_reservadas, 0L)

  calls_403 <- 0L
  budget_403 <- radar_novo_orcamento()
  expect_error(github_request(
    "GET /search/repositories", root = root, budget = budget_403,
    request_fn = function(path, query) {
      calls_403 <<- calls_403 + 1L
      list(.radar_http_status = 403L, .radar_http_body = list(message = "Forbidden"))
    }
  ), "HTTP 403")
  expect_equal(calls_403, 1L)
  expect_equal(budget_403$tentativas_reservadas, 1L)
  budget_repo_404 <- radar_novo_orcamento()
  expect_error(github_request(
    "GET /repos/example/missing", root = root, budget = budget_repo_404,
    public_only = TRUE,
    request_fn = function(path, query) {
      list(.radar_http_status = 404L, .radar_http_body = list(message = "Not Found"))
    }
  ), "HTTP 404")
  expect_equal(budget_repo_404$tentativas_reservadas, 1L)
  expect_error(radar_verificar_status_http(302L, "Hugging Face", "README.md"), "HTTP 302")
})

test_that("HF normalizer omits private-profile fields", {
  path <- testthat::test_path("..", "fixtures", "hf_models.json")
  fixture <- jsonlite::read_json(path, simplifyVector = FALSE)
  models <- hf_normalize_items(fixture, "models")
  expect_equal(models$id, "neuralmind/bert-base-portuguese-cased")
  expect_equal(models$url, "https://huggingface.co/neuralmind/bert-base-portuguese-cased")
  expect_equal(models$sha, strrep("a", 40))
  expect_false("email" %in% names(models))
  expect_false(any(grepl("must-not-be-read", unlist(models), fixed = TRUE)))
})

test_that("HF pagination stops after one page and records an available next page", {
  page <- 0L
  fake <- function(kind, query) {
    page <<- page + 1L
    if (page == 1L) list(items = list(list(id = "org/first")), "next" = "fixture-page-2") else
      list(items = list(list(id = "org/second")))
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  output <- hf_collect_query("models", list(author = "org", limit = 100), root,
                             request_fn = fake, max_pages = 1L, budget = budget)
  expect_equal(purrr::map_chr(output, "id"), "org/first")
  expect_equal(page, 1L)
  expect_true(attr(output, "pagination_summary")$has_next_page)
  expect_equal(budget$tentativas_reservadas, 1L)
  expect_error(hf_collect_query("models", list(), root, fake, max_pages = 2L,
                                budget = radar_novo_orcamento()), "exatamente uma")
})

test_that("HF collector queries only the explicitly selected seeded models account", {
  calls <- list()
  fake <- function(kind, query) {
    calls[[length(calls) + 1L]] <<- list(kind = kind, query = query)
    list(list(id = "example/fixture-model", sha = strrep("a", 40),
              likes = 1L, tags = character()))
  }
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  budget <- radar_novo_orcamento()
  output <- coletar_hf(seed_path, root, request_fn = fake, account = "example", budget = budget)
  expect_equal(length(calls), 1L)
  expect_equal(calls[[1]]$kind, "models")
  expect_equal(calls[[1]]$query$author, "example")
  expect_equal(calls[[1]]$query$limit, 100)
  expect_equal(calls[[1]]$query$full, "true")
  expect_equal(output$id, "example/fixture-model")
  enriched <- coletar_readme_hf(output, root = root,
                                request_fn = function(repo_id, kind, file) "Model card",
                                budget = budget)
  expect_equal(enriched$readme_status[[1]], "read")
  expect_match(enriched$content_hash[[1]], paste0("^huggingface:", strrep("a", 40), ":"))
  expect_match(attr(output, "radar_metadata")$account_check, "retornou modelos")
  expect_error(coletar_hf(seed_path, root, request_fn = fake, account = "other",
                          budget = radar_novo_orcamento()), "config/seeds.yml")
  expect_length(calls, 1L)
})

test_that("HF rejects a private item before caching", {
  root <- tempfile("radar-cache-"); dir.create(root)
  seed_path <- testthat::test_path("..", "fixtures", "seeds_minimal.yml")
  expect_error(coletar_hf(
    seed_path, root,
    request_fn = function(kind, query) list(list(id = "example/private", private = TRUE)),
    account = "example", budget = radar_novo_orcamento()
  ), "privado")
  expect_length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$"), 0L)
})

test_that("HF preserves and caches API errors without retrying", {
  root <- tempfile("radar-cache-"); dir.create(root)
  calls <- 0L
  fake <- function(kind, query) {
    calls <<- calls + 1L
    list(.radar_http_status = 403L, .radar_http_body = list(message = "rate limit"))
  }
  first_budget <- radar_novo_orcamento()
  expect_error(hf_collect_query(
    "models", list(author = "example", limit = 100), root,
    request_fn = fake, budget = first_budget
  ), "HTTP 403")
  expect_equal(calls, 1L)
  expect_equal(first_budget$tentativas_reservadas, 1L)

  cached_budget <- radar_novo_orcamento()
  expect_error(hf_collect_query(
    "models", list(author = "example", limit = 100), root,
    request_fn = fake, budget = cached_budget
  ), "HTTP 403")
  expect_equal(calls, 1L)
  expect_equal(cached_budget$tentativas_reservadas, 0L)
})

test_that("combined README enrichment selects at most ten URLs deterministically", {
  root <- tempfile("radar-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  repositories <- tibble::tibble(
    platform = c(rep("github", 6), rep("huggingface", 6)),
    url = c(paste0("https://github.com/org/repo", 1:6),
            paste0("https://huggingface.co/org/model", 1:6)),
    full_name = c(paste0("org/repo", 1:6), rep(NA_character_, 6)),
    id = c(rep(NA_character_, 6), paste0("org/model", 1:6)),
    kind = c(rep(NA_character_, 6), rep("models", 6)),
    sha = c(rep(NA_character_, 6), rep(strrep("a", 40), 6))
  )
  github_calls <- 0L
  hf_calls <- 0L
  github_fake <- function(path, query) {
    github_calls <<- github_calls + 1L
    list(content = jsonlite::base64_enc(charToRaw("README")))
  }
  hf_fake <- function(repo_id, kind, file) {
    hf_calls <<- hf_calls + 1L
    paste("Model card", repo_id)
  }

  result <- coletar_readmes_exploratorios(
    repositories, root, request_github_fn = github_fake,
    request_hf_fn = hf_fake, budget = budget
  )
  expect_length(result$selected_urls, 10L)
  expect_equal(result$selected_urls, c(
    "https://github.com/org/repo1", "https://huggingface.co/org/model1",
    paste0("https://github.com/org/repo", 2:6),
    paste0("https://huggingface.co/org/model", 2:4)
  ))
  expect_equal(nrow(result$documents), 10L)
  expect_equal(result$selection, list(
    eligible_distinct = 12L, selected = 10L, excluded_by_limit = 2L,
    prioritized_selected = 0L
  ))
  expect_equal(github_calls, 6L)
  expect_equal(hf_calls, 4L)
  expect_equal(budget$tentativas_reservadas, 14L)
  expect_equal(result$budget$documentos_selecionados, 10L)
})

test_that("README enrichment includes prioritized curated solutions inside the ten-document limit", {
  root <- tempfile("radar-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  curated_urls <- c(
    "https://github.com/antrologos/Transcritorio",
    "https://github.com/lfnovo/open-notebook",
    "https://github.com/LuizPF42/QualiLab"
  )
  repositories <- tibble::tibble(
    platform = c(rep("github", 3), rep("huggingface", 9)),
    url = c(curated_urls, paste0("https://huggingface.co/org/model", 1:9)),
    full_name = c(
      "antrologos/Transcritorio", "lfnovo/open-notebook", "LuizPF42/QualiLab",
      rep(NA_character_, 9)
    ),
    id = c(rep(NA_character_, 3), paste0("org/model", 1:9)),
    kind = c(rep(NA_character_, 3), rep("models", 9)),
    sha = c(rep(NA_character_, 3), rep(strrep("a", 40), 9))
  )
  result <- coletar_readmes_exploratorios(
    repositories, root,
    request_github_fn = function(path, query) {
      list(content = jsonlite::base64_enc(charToRaw("README")))
    },
    request_hf_fn = function(repo_id, kind, file) paste("Card", repo_id),
    priority_urls = curated_urls,
    budget = budget
  )
  expect_equal(nrow(result$documents), 10L)
  expect_true(all(curated_urls %in% result$selected_urls))
  expect_true(any(grepl("^https://huggingface.co/", result$selected_urls)))
  expect_equal(result$selection$prioritized_selected, 3L)
})

test_that("bounded enrichment reserves a document for every available platform", {
  root <- tempfile("radar-balanced-selection-"); dir.create(root)
  repositories <- tibble::tibble(
    platform = c(rep("github", 12), "huggingface", "gitlab"),
    url = c(paste0("https://github.com/org/repo", 1:12),
            "https://huggingface.co/org/model",
            "https://gitlab.com/org/project"),
    full_name = c(paste0("org/repo", 1:12), NA_character_, "org/project"),
    id = c(rep(NA_character_, 12), "org/model", "7001"),
    kind = c(rep(NA_character_, 12), "models", NA_character_),
    sha = c(rep(NA_character_, 12), strrep("a", 40), NA_character_)
  )
  github_fake <- function(path, query) {
    list(content = jsonlite::base64_enc(charToRaw("README")))
  }
  hf_fake <- function(repo_id, kind, file) "Model card"
  gitlab_fake <- function(method, path, query) {
    list(status = 200L, headers = list("X-Gitlab-Size" = "262145"))
  }

  result <- coletar_readmes_exploratorios(
    repositories, root,
    request_github_fn = github_fake,
    request_hf_fn = hf_fake,
    request_gitlab_fn = gitlab_fake,
    priority_urls = "https://github.com/org/repo12",
    budget = radar_novo_orcamento()
  )

  expect_equal(nrow(result$documents), 10L)
  expect_equal(result$selected_urls[[1]], "https://github.com/org/repo12")
  expect_equal(result$selection$prioritized_selected, 1L)
  expect_true(all(c("github", "huggingface", "gitlab") %in% result$documents$platform))
  expect_equal(result$documents$readme_status[result$documents$platform == "gitlab"], "over_size_limit")
})
