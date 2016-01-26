git_ignore <- function(ignores, repo = ".") {
  if (!is_a_repo(repo)) {
    stop("'repo' does not appear to be a path to a Git repository:\n",
         repo, call. = FALSE)
  }

  gi_path <- normalizePath(file.path(repo, ".gitignore"), winslash = "/",
                           mustWork = FALSE)

  if (!file.exists(gi_path)) {
    message("Creating .gitignore")
    file.create(gi_path)
  }

  message("Adding this to .gitignore:")
  gi_contents <- union_write(gi_path, ignores)
  message(paste("  ", gi_contents, collapse = "\n"))
  gi_path
}
