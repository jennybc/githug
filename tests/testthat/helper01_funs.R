tmp_repo_path <-
  function(x = "", slug = "githug-test", user = Sys.info()["user"]) {
    if (x != "") x <- paste0(x, "-")
    tempfile(paste(slug, user, x, sep = "-"))
  }

init_tmp_repo <- function(x = "",
                          slug = "githug-test",
                          user = Sys.info()["user"]) {
  tpath <- tmp_repo_path(x = x, slug = slug, user = user)
  git_init(tpath)
}

read_git_config <- function(path) {
  alt_path <- git2r::discover_repository(path)
  path <- if (is.null(alt_path)) path else file.path(alt_path, "config")
  raw <- readLines(path)
  raw <- gsub("\t", "", raw)
  section <- cumsum(grepl("\\[.*\\]", raw))
  sections <- split(raw, section)
  sections <- sections[lengths(sections) > 1L]
  names(sections) <- NULL
  as.list(unlist(lapply(sections, function(x) {
    s <- gsub('\\[|\\]', "", x[1])
    s <- gsub('"', "", s)
    s <- gsub("\\s", ".", s)
    vars <- strsplit(x[-1], " = ")
    var_names <- vapply(vars, `[`, character(1), 1)
    var_names <- paste(s, var_names, sep = ".")
    as.list(setNames(vapply(vars, `[`, character(1), 2), var_names))
  })))
}

## writes, e.g., "a" and "b" as the contents of files "a" and "b"
write_file <- function(x, dir = NULL) {
  paths <- if (is.null(dir)) x else file.path(dir, x)
  purrr::map2(x, paths, write)
}

## limits comparison to columns you bothered to include in reference
expect_status <- function(status, reference) {
  expect_identical(status[names(reference)], reference)
}
