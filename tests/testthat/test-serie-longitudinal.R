test_that("platform IDs are namespaced and mutable URLs are rejected as numeric IDs", {
  expect_equal(radar_artifact_id("github", "123"), "github:123")
  expect_equal(radar_artifact_id("gitlab", "45"), "gitlab:45")
  expect_equal(radar_artifact_id("huggingface", "org/model", "models"),
               "huggingface:models:org/model")
  expect_error(radar_artifact_id("github", "https://github.com/org/repo"))
  expect_error(radar_artifact_id("huggingface", "model", "models"))
})

test_that("two synthetic runs retain change, absence and HTTP 404 as distinct events", {
  first <- tibble::tibble(
    artifact_id = c("github:1", "gitlab:2", "huggingface:models:org/model"),
    content_hash = c("hash-a", "hash-b", "hash-c"),
    status = c("ok", "ok", "ok")
  )
  second <- tibble::tibble(
    artifact_id = c("github:1", "huggingface:models:org/model", "github:3"),
    content_hash = c("hash-a2", NA_character_, "hash-d"),
    status = c("ok", "http_404", "ok")
  )
  events <- radar_eventos_rodada("2026-09-28", second, first)
  expect_equal(events$evento[match(c("github:1", "gitlab:2", "huggingface:models:org/model", "github:3"),
                                   events$artifact_id)],
               c("alterado", "ausente_da_busca", "http_404", "novo"))
  expect_false(any(grepl("excluido|encerrado", events$evento)))
  expect_error(radar_eventos_rodada("next", rbind(second, second[1, ]), first))
})

test_that("run manifests stay outside the repository and cannot overwrite a run", {
  root <- tempfile("radar-runs-"); dir.create(root)
  manifesto <- list(run_id = "fixture-1", timestamp_utc = "2026-09-28T00:00:00Z",
                    janela = list(inicio = "2026-09-21", fim = "2026-09-28"),
                    collector_commit = "fixture", collector_version = "fixture",
                    codebook_version = "0.2.0", decifra_commit = NA_character_,
                    decifra_version = NA_character_, consultas = list(),
                    status_http = list(), totais = list(), paginas_lidas = 0L,
                    falhas = list(), cache_ref = "fixture")
  path <- radar_salvar_manifesto_rodada(manifesto, root)
  expect_true(file.exists(path))
  expect_true(startsWith(normalizePath(path, winslash = "/"), normalizePath(root, winslash = "/")))
  expect_error(radar_salvar_manifesto_rodada(manifesto, root))
})
