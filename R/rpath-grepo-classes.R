## goal: insulate user from the git2r S4 git_repository class + methods
## instead, we're always going to identify the repo via its path
##
## S3 classes here
##
## rpath: path to working directory of a git repo = parent dir of.git
## consistent with interactive use, so not worrying about bare repos
##
## grepo: list that holds rpath and other useful info on the repo
## possibly useful internally? we'll see
##
## review of relevant git2r stuff
## discover_repository():
##  * input = path like ~/foo ~/foo/ ~/foo.git ~/foo.git/
##  * output = path like ~/foo/.git/ <-- note the terminating file separator
## repository():
##  * input = path like ~/foo ~/foo/ ~/foo.git ~/foo.git/
##  * output = git_repository object
##  * init() also returns these
##  * repository will walk up parents iff discover = TRUE (should probably
##    be re-thought now that we have ceiling arg in discover_repository?)
## workdir():
##  * input = git_repository object
##  * output = path like ~/foo/  <-- note the terminating file separator
##    note: returns NULL if bare repo

## rpath ------------------------------------------

as.rpath <- function(x, ...) UseMethod("as.rpath")

as.rpath.rpath <- function(x, ...) x

as.rpath.character <- function(x, ...) {

  stopifnot(length(x) == 1L)

  x <- normalizePath(x)
  ## TO DECIDE: do I want to set ceiling here? right now we walk up
  xrepo <- git2r::discover_repository(x)
  if (is.null(xrepo)) {
    message("path does not seem to be or be inside a git repo:\n", x)
    return(invisible(NULL))
  }
  ## why not use repository(..., discover = TRUE) directly on x?
  ## because it errors if can't discover repo, so would require try() anyway
  structure(git2r::workdir(git2r::repository(xrepo, discover = TRUE)),
            class = "rpath")

}

as.rpath.git_repository <- function(x, ...) as.rpath(git2r::workdir(x))

is.rpath <- function(x) inherits(x, "rpath")

print.rpath <- function(x) print(as.character(x))

## grepo ------------------------------------------

as.grepo <- function(x, ...) UseMethod("as.grepo")

as.grepo.grepo <- function(x, ...) x

as.grepo.character <- function(x, ...) grepo(as.rpath(x))

as.grepo.git_repository <-
  function(x, ...) as.grepo(as.rpath(git2r::workdir(x)))

grepo <- function(rpath) {
  ## more stuff will go here
  structure(list(
    path = rpath
  ), class = c("grepo", "list"))
}

is.grepo <- function(x) inherits(x, "grepo")

print.grepo <- function(g) {
  cat(sprintf(
    "path: %s\n", g$path
  ))
}

## git_repository ------------------------------------------

as_git_repository <- function(x = ".") {

  stopifnot(inherits(x, c("character", "rpath", "grepo", "git_repository")))

  if (inherits(x, "git_repository"))
    return(invisible(x))

  if (inherits(x, "grepo"))
    x <- x$path

  git2r::repository(as.character(as.rpath(x)))

}

