git_init <- function(path = ".", ...) {

  path <- normalizePath(path, mustWork = FALSE)
  if (dir.exists(path)) {
    if (!is.null(as.grepo(path)))
      stop(path, " appears to already be a git repo!")
  } else {
    message("Creating directory ", path)
    dir.create(path, recursive = TRUE)
  }

  message("Creating git repo in ", path)
  repo <- git2r::init(path, ...)
  ## should this return path to repo or grepo object?
  as.rpath(repo)

}
