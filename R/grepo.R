as.grepo <- function(x, ...) UseMethod("as.grepo")

as.grepo.grepo <- function(x, ...) x

as.grepo.character <- function(x, ...) grepo(x)

grepo <- function(x = ".") {
  x <- normalizePath(x)
  xrepo <- git2r::discover_repository(x, ceiling = 0)
  if (is.null(xrepo)) {
    message("path does not seem to be a git repo:\n", x)
    return(invisible(NULL))
  }
  xrepo <- git2r::workdir(git2r::repository(xrepo, discover = TRUE))
  structure(list(path = xrepo), class = c("grepo", "list"))
}

is.grepo <- function(x) inherits(x, "grepo")

print.grepo <- function(g) {
  cat(sprintf("path: %s\n", g$path))
}

as_git_repository <- function(g = ".", ceiling = 0) {
  if (inherits(g, "grepo"))
    g <- g$path
  git2r::repository(g, discover = TRUE)
}

