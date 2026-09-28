test_that("raw response cache is external and round-trips JSON", {
  root <- tempfile("radar-root-")
  dir.create(root)
  key <- list(provider = "fixture", query = "no network")
  value <- list(items = list(list(id = 1L, name = "example")))
  radar_cache_write(key, value, root)
  expect_equal(radar_cache_read(key, root), value)
  expect_false(startsWith(radar_cache_path(key, root), normalizePath(".", winslash = "/")))
})

test_that("cache drops email fields and redacts addresses embedded in prose", {
  root <- tempfile("radar-root-"); dir.create(root)
  key <- list(provider = "fixture", query = "privacy")
  radar_cache_write(key, list(email = "secret@example.invalid", description = "contact secret@example.invalid"), root)
  output <- radar_cache_read(key, root)
  expect_false("email" %in% names(output))
  expect_false(any(grepl("secret@example.invalid", unlist(output), fixed = TRUE)))
})

test_that("cache redacts README text encoded by the GitHub API", {
  root <- tempfile("radar-root-"); dir.create(root)
  key <- list(provider = "github", endpoint = "readme")
  encoded <- jsonlite::base64_enc(charToRaw("Contact author@example.invalid"))
  radar_cache_write(key, list(encoding = "base64", content = encoded), root)
  cached <- radar_cache_read(key, root)
  decoded <- rawToChar(jsonlite::base64_dec(cached$content))
  expect_false(grepl("author@example.invalid", decoded, fixed = TRUE))
  expect_match(decoded, "EMAIL REDACTED")
})

test_that("cache refresh predicates receive the saved response time", {
  root <- tempfile("radar-root-"); dir.create(root)
  key <- list(provider = "fixture", query = "refresh")
  calls <- 0L
  fetch <- function() {
    calls <<- calls + 1L
    list(value = calls)
  }
  expect_equal(radar_cached(key, fetch, root), list(value = 1L))
  expect_equal(radar_cached(key, fetch, root, refresh_if = function(value, saved_at) {
    expect_true(inherits(saved_at, "POSIXt"))
    value$value == 1L
  }), list(value = 2L))
  expect_equal(calls, 2L)
})

test_that("cache refuses an implicit in-repository fallback", {
  old <- Sys.getenv("MANCANO_BBSIA_RADAR_ROOT", unset = NA_character_)
  Sys.unsetenv("MANCANO_BBSIA_RADAR_ROOT")
  on.exit(if (is.na(old)) Sys.unsetenv("MANCANO_BBSIA_RADAR_ROOT") else Sys.setenv(MANCANO_BBSIA_RADAR_ROOT = old))
  expect_error(radar_cache_root(), "MANCANO_BBSIA_RADAR_ROOT")
})
