init_tmp_repo <-
  function(slug = "github-test-") git_init(tempfile(pattern = slug))

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
