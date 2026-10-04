contexto_root <- function() {
  root <- tempfile("radar-cache")
  dir.create(root)
  root
}

test_that("context counts releases and contributors and profiles organisations only", {
  calls <- character()
  fake <- function(path, query) {
    calls <<- c(calls, path)
    switch(path,
      "GET /repos/org/a/releases" = list(list(tag_name = "v1"), list(tag_name = "v2")),
      "GET /repos/org/a/contributors" = list(list(login = "p1"), list(login = "p2"), list(login = "p3")),
      "GET /repos/pessoa/b/releases" = list(),
      "GET /repos/pessoa/b/contributors" = list(list(login = "pessoa")),
      "GET /orgs/org" = list(name = "Lab Org", description = "Laboratório", blog = "https://lab.br",
                             location = "Recife, Brasil", email = "nao@guardar.br"),
      stop("caminho inesperado: ", path))
  }
  repos <- tibble::tibble(full_name = c("org/a", "pessoa/b"), owner = c("org", "pessoa"),
                          owner_type = c("Organization", "User"))
  out <- coletar_contexto_github(repos, contexto_root(), fake, radar_novo_orcamento(20L, 2L))
  expect_equal(out$releases, c(2L, 0L))
  expect_equal(out$contribuidores, c(3L, 1L))
  expect_equal(out$org_local, c("Recife, Brasil", NA))
  expect_equal(out$org_site, c("https://lab.br", NA))
  expect_false("GET /users/pessoa" %in% calls)
  expect_false(any(grepl("guardar", unlist(out))))
  expect_false(any(c("p1", "p2", "pessoa") %in% unlist(out[c("releases", "contribuidores")])))
})

test_that("the corpus document cites the context lines when present", {
  rows <- tibble::tibble(name = "a", url = "https://github.com/org/a", owner = "org", description = NA,
                         topics = list("nlp"), readme = "README", owner_type = "Organization",
                         org_nome = "Lab Org", org_local = "Recife, Brasil", homepage = "https://a.br",
                         license = "MIT", releases = 2L, contribuidores = 3L)
  doc <- documento_solucao(rows)
  expect_match(doc, "Tipo de dono: organização")
  expect_match(doc, "Localização declarada pela organização: Recife, Brasil")
  expect_match(doc, "Site do projeto: https://a.br")
  expect_match(doc, "Releases publicadas (até 100): 2", fixed = TRUE)
  pessoa <- tibble::tibble(name = "b", url = "u", owner = "p", description = NA, topics = list(character()),
                           readme = NA, owner_type = "User")
  expect_match(documento_solucao(pessoa), "Tipo de dono: pessoa")
  expect_false(grepl("Localização", documento_solucao(pessoa)))
})

test_that("only the dedicated public-read token is sent, never a general GITHUB_PAT", {
  old <- Sys.getenv(c("GITHUB_PAT", "BBSIA_RADAR_GITHUB_TOKEN"), NA)
  on.exit(for (k in names(old)) if (is.na(old[[k]])) Sys.unsetenv(k) else do.call(Sys.setenv, as.list(old[k])))
  Sys.setenv(GITHUB_PAT = "geral-nao-enviar")
  Sys.unsetenv("BBSIA_RADAR_GITHUB_TOKEN")
  expect_null(github_http_request("GET /repos/a/b")$headers$Authorization)
  Sys.setenv(BBSIA_RADAR_GITHUB_TOKEN = "token-de-teste")
  # httr2 keeps the secret obfuscated; the header must exist.
  expect_true("Authorization" %in% names(github_http_request("GET /repos/a/b")$headers))
})

test_that("the cache keeps only counts and the organisation allow-list, and 409 does not stop the round", {
  root <- contexto_root()
  fake <- function(path, query) {
    switch(path,
      "GET /repos/org/a/releases" = list(list(tag_name = "v1", author = list(login = "autor-release"))),
      "GET /repos/org/a/contributors" = list(list(login = "contribuidora-secreta")),
      "GET /repos/org/vazio/releases" = list(.radar_http_status = 409L, .radar_http_body = list(message = "empty")),
      "GET /repos/org/vazio/contributors" = list(.radar_http_status = 409L, .radar_http_body = list(message = "empty")),
      "GET /orgs/org" = list(name = "Lab", description = "d", blog = "b", location = "Recife",
                             email = "contato@org.br", members_url = "membros-secretos"),
      stop("caminho inesperado: ", path))
  }
  repos <- tibble::tibble(full_name = c("org/a", "org/vazio"), owner = "org", owner_type = "Organization")
  out <- coletar_contexto_github(repos, root, fake, radar_novo_orcamento(20L, 2L))
  expect_equal(out$contribuidores, c(1L, NA))
  expect_equal(out$releases, c(1L, NA))
  cache <- paste(vapply(list.files(root, recursive = TRUE, full.names = TRUE), readr::read_file, character(1)),
                 collapse = "\n")
  expect_false(grepl("contribuidora-secreta|autor-release|membros-secretos|contato@org", cache))
  expect_match(cache, "Recife")
  rate <- function(path, query) list(.radar_http_status = 403L, .radar_http_body = list(message = "rate limit"))
  expect_error(coletar_contexto_github(repos[1, ], contexto_root(), rate, radar_novo_orcamento(20L, 2L)), "403")
})

test_that("a renamed repository (HTTP 301) leaves its README and counts missing without stopping", {
  moved <- function(path, query) list(.radar_http_status = 301L, .radar_http_body = list(message = "Moved Permanently"))
  repos <- tibble::tibble(full_name = "dono/antigo", url = "https://github.com/dono/antigo", owner = "dono",
                          owner_type = "User")
  lido <- coletar_readme_github(repos, contexto_root(), moved, radar_novo_orcamento(20L, 2L))
  expect_true(is.na(lido$readme))
  ctx <- coletar_contexto_github(repos, contexto_root(), moved, radar_novo_orcamento(20L, 2L))
  expect_true(is.na(ctx$releases) && is.na(ctx$contribuidores))
})

test_that("absences keep their reason: moved GitHub repository and gated Hugging Face card", {
  moved <- function(path, query) list(.radar_http_status = 301L, .radar_http_body = list(message = "Moved"))
  repos <- tibble::tibble(full_name = "dono/antigo", url = "https://github.com/dono/antigo")
  expect_equal(coletar_readme_github(repos, contexto_root(), moved, radar_novo_orcamento(20L, 2L))$readme_status, "movido")
  gated <- function(repo_id, kind, file) list(.radar_http_status = 401L, .radar_http_body = "gated")
  hf <- tibble::tibble(id = "org/gated", kind = "models", sha = strrep("a", 40))
  lido <- coletar_readme_hf(hf, contexto_root(), gated, radar_novo_orcamento(20L, 2L))
  expect_equal(lido$readme_status, "restrito")
  expect_true(is.na(lido$readme))
  limite <- function(repo_id, kind, file) list(.radar_http_status = 429L, .radar_http_body = "rate")
  expect_error(coletar_readme_hf(hf, contexto_root(), limite, radar_novo_orcamento(20L, 2L)), "429")
})
