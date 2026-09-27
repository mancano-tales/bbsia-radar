# The repository's R/ directory contains small functions rather than a package
# namespace yet. Loading them here gives testthat the same source files as a
# normal local run while keeping the test suite fully offline.
repo_root <- normalizePath(testthat::test_path("..", ".."), winslash = "/")
setwd(repo_root)
for (file in list.files(file.path(repo_root, "R"), pattern = "\\.R$", full.names = TRUE)) {
  sys.source(file, envir = .GlobalEnv)
}
