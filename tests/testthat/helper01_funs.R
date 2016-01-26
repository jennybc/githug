tmp_repo_path <- function(x = "",
                          slug = "githug-test",
                          user = Sys.info()["user"]) {
  if (x != "") x <- paste0(x, "-")
  tempfile(paste(slug, user, x, sep = "-"))
}

init_tmp_repo <- function(x = "",
                          slug = "githug-test",
                          user = Sys.info()["user"]) {
  git_init(tmp_repo_path(x = x, slug = slug, user = user))
}

read_git_config <- function(path) {
  alt_path <- git2r::discover_repository(path)
  path <- if (is.null(alt_path)) path else file.path(alt_path, "config")
  raw <- readLines(path)
  raw <- gsub("\t", "", raw)
  section <- cumsum(grepl("\\[.*\\]", raw))
  sections <- split(raw, section)
  sections <- sections[vapply(sections, length, integer(1)) > 1L]
  names(sections) <- NULL
  unlist(lapply(sections, function(x) {
    s <- gsub("\\[|\\]", "", x[1])
    vars <- strsplit(x[-1], " = ")
    var_names <- vapply(vars, `[`, character(1), 1)
    var_names <- paste(s, var_names, sep = ".")
    vars <- as.list(setNames(vapply(vars, `[`, character(1), 2), var_names))
    vars
  }))
}
