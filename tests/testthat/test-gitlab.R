test_that("GitLab normalizer keeps the public project contract and activity meaning", {
  fixture_path <- testthat::test_path("..", "fixtures", "gitlab_projects.json")
  fixture <- jsonlite::read_json(fixture_path, simplifyVector = FALSE)
  projects <- gitlab_normalize_items(fixture)

  expect_equal(projects$platform, "gitlab")
  expect_equal(projects$id, "7001")
  expect_equal(projects$full_name, "fixture/fixture-public")
  expect_equal(projects$url, "https://gitlab.com/fixture/fixture-public")
  expect_equal(projects$owner, "fixture")
  expect_equal(projects$stars, 2L)
  expect_equal(projects$topics[[1]], c("pt-BR", "ai"))
  expect_equal(projects$updated_at_semantics, "project_activity_at")
  expect_false("email" %in% names(projects))
})

test_that("GitLab seed terms include exact solution names and artifact path names", {
  seed_path <- testthat::test_path("..", "..", "config", "seeds.yml")
  seeds <- yaml::yaml.load(readr::read_file(seed_path))
  expect_true("Transcritorio" %in% gitlab_seed_terms(seeds))
  expect_true("BERTimbau" %in% gitlab_seed_terms(seeds))
  expect_true("BERTimbau" %in% github_seed_terms(seeds))
  expect_error(gitlab_validar_termos("not-a-seed", seeds), "config/seeds.yml")
  expect_error(gitlab_validar_termos(c("Transcritorio", "BERTimbau", "third"), seeds), "dois termos")
})

test_that("GitLab search is anonymous, bounded, sorted, and records truncation", {
  fixture <- jsonlite::read_json(testthat::test_path("..", "fixtures", "gitlab_projects.json"),
                                 simplifyVector = FALSE)
  calls <- list()
  request_fn <- function(method, path, query) {
    calls[[length(calls) + 1L]] <<- list(method = method, path = path, query = query)
    list(
      status = 200L,
      headers = list("X-Total" = "150", "X-Total-Pages" = "2", "X-Next-Page" = "2"),
      body = fixture
    )
  }
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  budget <- radar_novo_orcamento()
  projects <- coletar_gitlab(
    testthat::test_path("..", "..", "config", "seeds.yml"), root, request_fn = request_fn,
    search_terms = c("Transcritorio", "BERTimbau"), budget = budget
  )

  expect_equal(length(calls), 2L)
  expect_true(all(purrr::map_chr(calls, "method") == "GET"))
  expect_true(all(purrr::map_chr(calls, "path") == "/projects"))
  expect_equal(purrr::map_chr(calls, ~ .x$query$search), c("Transcritorio", "BERTimbau"))
  expect_true(all(purrr::map_lgl(calls, ~ identical(.x$query$visibility, "public"))))
  expect_true(all(purrr::map_lgl(calls, ~ isTRUE(.x$query$simple))))
  expect_true(all(purrr::map_int(calls, ~ .x$query$page) == 1L))
  expect_true(all(purrr::map_int(calls, ~ .x$query$per_page) == 100L))
  expect_true(all(purrr::map_chr(calls, ~ .x$query$order_by) == "created_at"))
  expect_true(all(purrr::map_chr(calls, ~ .x$query$sort) == "desc"))
  # The same project may be returned for both query terms; keep one canonical row.
  expect_equal(nrow(projects), 1L)
  expect_true(all(attr(projects, "radar_metadata")$searches$truncated))
  expect_equal(budget$tentativas_reservadas, 2L)
})

test_that("GitLab cache keeps only needed headers and expires temporary errors", {
  normalized <- gitlab_normalize_response(list(
    status = 429L,
    headers = list(
      "Retry-After" = "120", "Set-Cookie" = "session=private",
      "X-Gitlab-Commit-Id" = "abc123", "X-Request-Id" = "private-id"
    ),
    body = list(message = "rate limited")
  ))
  expect_equal(names(normalized$.radar_headers), c("retry-after", "x-gitlab-commit-id"))
  expect_false("session=private" %in% unlist(normalized))
  now <- as.POSIXct("2026-09-27 12:00:00", tz = "UTC")
  cached <- list(.radar_http_status = 429L, .radar_headers = list("retry-after" = "120"))
  expect_false(gitlab_cache_error_expired(cached, now - 60, now))
  expect_true(gitlab_cache_error_expired(cached, now - 121, now))
  cached_date <- list(
    .radar_http_status = 429L,
    .radar_headers = list("retry-after" = "Sun, 27 Sep 2026 13:00:00 GMT")
  )
  before_retry_date <- as.POSIXct("2026-09-27 12:30:00", tz = "UTC")
  at_retry_date <- as.POSIXct("2026-09-27 13:00:00", tz = "UTC")
  expect_false(gitlab_cache_error_expired(cached_date, now, before_retry_date))
  expect_true(gitlab_cache_error_expired(cached_date, now, at_retry_date))
  expect_false(gitlab_cache_error_expired(
    list(.radar_http_status = 404L), now - 3600, now
  ))
})

test_that("GitLab rejects missing or non-public visibility before caching", {
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  fixture <- jsonlite::read_json(testthat::test_path("..", "fixtures", "gitlab_projects.json"),
                                 simplifyVector = FALSE)
  missing_visibility <- fixture
  missing_visibility[[1]]$visibility <- NULL
  expect_error(gitlab_search_page(
    "Transcritorio", root,
    request_fn = function(method, path, query) list(status = 200L, body = missing_visibility),
    budget = radar_novo_orcamento()
  ), "visibility=public")
  expect_length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$"), 0L)

  private <- fixture
  private[[1]]$visibility <- "private"
  expect_error(gitlab_search_page(
    "Transcritorio", root,
    request_fn = function(method, path, query) list(status = 200L, body = private),
    budget = radar_novo_orcamento()
  ), "visibility=public")
  expect_length(list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$"), 0L)
})

test_that("GitLab README uses HEAD before GET, enforces the byte ceiling, and redacts email", {
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  README <- "T\u00edtulo pt-BR; contato teste@example.invalid"
  encoded <- jsonlite::base64_enc(charToRaw(README))
  calls <- list()
  request_fn <- function(method, path, query) {
    calls[[length(calls) + 1L]] <<- list(method = method, path = path, query = query)
    if (identical(method, "HEAD")) {
      return(list(status = 200L, headers = list(
        "X-Gitlab-Size" = as.character(nchar(README, type = "bytes")),
        "X-Gitlab-Commit-Id" = "commit-7001", "X-Gitlab-Blob-Id" = "blob-7001"
      )))
    }
    list(status = 200L, body = list(
      size = nchar(README, type = "bytes"), encoding = "base64", content = encoded,
      file_path = "README.md", commit_id = "commit-7001", blob_id = "blob-7001",
      last_commit_id = strrep("c", 40)
    ))
  }
  budget <- radar_novo_orcamento()
  input <- tibble::tibble(id = "7001", url = "https://gitlab.com/fixture/fixture-public")
  result <- coletar_readme_gitlab(input, root, request_fn, budget)

  expect_equal(purrr::map_chr(calls, "method"), c("HEAD", "GET"))
  expect_true(all(purrr::map_chr(calls, "path") == "/projects/7001/repository/files/README.md"))
  expect_equal(purrr::map_chr(calls, ~ .x$query$ref), c("HEAD", "commit-7001"))
  expect_match(result$readme, "T\u00edtulo pt-BR")
  expect_match(result$readme, "EMAIL REDACTED")
  expect_equal(result$readme_status, "read")
  expect_match(result$content_hash[[1]], paste0("^gitlab:", strrep("c", 40), ":"))
  expect_equal(budget$tentativas_reservadas, 2L)
  expect_equal(budget$documentos, "gitlab:7001")
})

test_that("GitLab does not GET an oversized or missing README and caches the result", {
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  calls <- character()
  oversized <- function(method, path, query) {
    calls <<- c(calls, method)
    list(status = 200L, headers = list("X-Gitlab-Size" = "262145"))
  }
  input <- tibble::tibble(id = "7001", url = "https://gitlab.com/fixture/large")
  large_budget <- radar_novo_orcamento()
  large <- coletar_readme_gitlab(input, root, oversized, large_budget)
  expect_equal(calls, "HEAD")
  expect_true(is.na(large$readme))
  expect_equal(large$readme_status, "over_size_limit")
  expect_equal(large_budget$tentativas_reservadas, 1L)

  missing_calls <- 0L
  missing <- function(method, path, query) {
    missing_calls <<- missing_calls + 1L
    list(status = 404L)
  }
  missing_budget <- radar_novo_orcamento()
  absent <- coletar_readme_gitlab(
    tibble::tibble(id = "7002", url = "https://gitlab.com/fixture/no-readme"),
    root, missing, missing_budget
  )
  expect_true(is.na(absent$readme))
  expect_equal(absent$readme_status, "missing")
  expect_equal(missing_calls, 1L)
  expect_equal(missing_budget$tentativas_reservadas, 1L)

  cached_budget <- radar_novo_orcamento()
  again <- coletar_readme_gitlab(
    tibble::tibble(id = "7002", url = "https://gitlab.com/fixture/no-readme"),
    root, missing, cached_budget
  )
  expect_true(is.na(again$readme))
  # HEAD is deliberately refreshed every round even when the file is absent.
  expect_equal(missing_calls, 2L)
  expect_equal(cached_budget$tentativas_reservadas, 1L)
})

test_that("GitLab refuses cache sizes above 256 KiB and never caches oversized Base64", {
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  input <- tibble::tibble(id = "7001", url = "https://gitlab.com/fixture/large")
  expect_error(coletar_readme_gitlab(
    input, root, request_fn = function(...) stop("should not call API"),
    budget = radar_novo_orcamento(), max_bytes = 256L * 1024L + 1L
  ), "256 KiB")

  calls <- character()
  too_large <- function(method, path, query) {
    calls <<- c(calls, method)
    if (method == "HEAD") {
      return(list(status = 200L, headers = list(
        "X-Gitlab-Size" = "10", "X-Gitlab-Commit-Id" = "commit-7001",
        "X-Gitlab-Blob-Id" = "blob-7001"
      )))
    }
    list(status = 200L, body = list(
      size = 10L, encoding = "base64", content = strrep("A", 4L * ceiling((256L * 1024L) / 3L) + 1L),
      file_path = "README.md", commit_id = "commit-7001", blob_id = "blob-7001"
    ))
  }
  result <- coletar_readme_gitlab(input, root, too_large, radar_novo_orcamento())
  expect_equal(calls, c("HEAD", "GET"))
  expect_true(is.na(result$readme))
  expect_equal(result$readme_status, "over_size_limit_after_get")
  cached_files <- list.files(file.path(root, "bbsia-radar", "api"), pattern = "json$", full.names = TRUE)
  expect_true(length(cached_files) >= 2L)
  cache_contents <- paste(vapply(cached_files, readr::read_file, character(1)), collapse = "\n")
  expect_false(grepl(strrep("A", 100L), cache_contents, fixed = TRUE))
})

test_that("shared enrichment routes GitLab through the same ten-document ceiling", {
  root <- tempfile("radar-gitlab-cache-"); dir.create(root)
  repositories <- tibble::tibble(
    platform = "gitlab",
    id = "7001",
    url = "https://gitlab.com/fixture/fixture-public",
    full_name = "fixture/fixture-public"
  )
  request_fn <- function(method, path, query) {
    if (identical(method, "HEAD")) {
      return(list(status = 200L, headers = list(
        "X-Gitlab-Size" = "7", "X-Gitlab-Commit-Id" = "commit-7001",
        "X-Gitlab-Blob-Id" = "blob-7001"
      )))
    }
    list(status = 200L, body = list(
      size = 7L, encoding = "base64", content = jsonlite::base64_enc(charToRaw("README")),
      file_path = "README.md", commit_id = "commit-7001", blob_id = "blob-7001"
    ))
  }
  result <- coletar_readmes_exploratorios(
    repositories, root, request_gitlab_fn = request_fn,
    budget = radar_novo_orcamento()
  )
  expect_equal(result$selection$selected, 1L)
  expect_equal(result$documents$readme, "README")
  expect_equal(result$budget$documentos_selecionados, 1L)
  expect_equal(result$budget$tentativas_reservadas, 2L)
})

test_that("corpus keeps an unlinked GitLab candidate separate and explains project activity", {
  seed_path <- testthat::test_path("..", "..", "config", "seeds.yml")
  seeds <- yaml::yaml.load(readr::read_file(seed_path))
  project <- tibble::tibble(
    platform = "gitlab", id = "7001", full_name = "fixture/fixture-public",
    name = "fixture-public", description = "fixture", url = "https://gitlab.com/fixture/fixture-public",
    owner = "fixture", updated_at = "2026-09-01", updated_at_semantics = "project_activity_at",
    topics = list(character()), readme = "README evidence"
  ) |>
    aplicar_ids_sementes(seeds)
  corpus <- montar_corpus(gitlab = project)
  expect_equal(corpus$id, "https://gitlab.com/fixture/fixture-public")
  expect_match(corpus$text, "last_activity_at")
  expect_match(corpus$text, "nao equivale a ultimo commit")
})
