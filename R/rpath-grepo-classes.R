## goal: insulate user from the git2r S4 git_repository class + methods
## instead, we're always going to identify the repo via its path
##
## S3 classes here
##
## rpath: path to working directory of a git repo = parent dir of .git
## targetting interactive use, so not worrying about bare repos
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
##    note: returns NULL if bare repo, which I don't address

## rpath ------------------------------------------

as.rpath <- function(x, ...) UseMethod("as.rpath")

as.rpath.rpath <- function(x, ...) x

as.rpath.character <- function(x, ...) {

  stopifnot(length(x) == 1L)

  x <- normalizePath(x)
  ## TO DECIDE: do I want to set ceiling here? right now we walk up
  xrepo <- git2r::discover_repository(x)
  if (is.null(xrepo)) {
    #message("path does not seem to be or be inside a git repo:\n", x)
    return(invisible(NULL))
  }
  ## why not use repository(..., discover = TRUE) directly on x?
  ## because it errors if can't discover repo, so would require try() anyway
  structure(
    normalizePath(git2r::workdir(git2r::repository(xrepo, discover = TRUE))),
    class = "rpath"
  )

}

as.rpath.git_repository <- function(x, ...) as.rpath(git2r::workdir(x))

is.rpath <- function(x) inherits(x, "rpath")

is_in_repo <- function(x) !is.null(as.rpath(x))

##is_a_repo <- function(x) ??/

print.rpath <- function(x) print(as.character(x))

## grepo ------------------------------------------

as.grepo <- function(x, ...) UseMethod("as.grepo")

as.grepo.grepo <- function(x, ...) x

as.grepo.character <- function(x, ...) {
  x_rpath <- as.rpath(x)
  if (is.null(x_rpath))
    return(NULL)
  else
    grepo(x_rpath)
}

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

#' Open a Git repository, the git2r way
#'
#' \code{\link{githug}} uses the \code{\link{git2r}} package, under the hood, to
#' perform local Git operations. \code{\link{git2r}} handles Git repos as
#' objects of class \code{\linkS4class{git_repository}}. Use this function to
#' convert a path (or other way of referring to a Git repo) to the right sort of
#' input. You might need this to do less common Git operations, i.e. to call
#' \code{\link{git2r}} functions that aren't exposed via  \code{\link{githug}}.
#'
#' @param x Git repository specified as a path. Or as an object of class
#'   \code{rpath} or code{grepo} (classes used internally in the
#'   \code{\link{githug}} package) or of class
#'   \code{\linkS4class{git_repository}} (from the \code{\link{git2r}} package).
#'
#' @return An S4 \code{\linkS4class{git_repository}} object
#' @export
#'
#' @examples
#' repo <- tempfile(pattern = "githug-to-git2r-example-")
#' git_init(repo)
#' git_config(repo = repo, user.name="jd", user.email="jd@example.org")
#' writeLines(paste("Well, I've always believed that if done properly, armed",
#'                  "robbery doesn't have to be an unpleasant experience."),
#'                  file.path(repo, "example.txt"))
#' ## TO DO: revisit once I've wrapped add, status, commit, etc.
#' git2r::add(as_git_repository(repo), "example.txt")
#' git2r::commit(as_git_repository(repo), "jd is a smooth talker")
#'
#' ## here's a rather exotic Git operation that githug is unlikely to expose:
#' ## odb_blobs() lists "all blobs reachable from the commits in the object database"
#' ## pre-process the repo with as_git_repository() to prepare for git2r
#' git2r::odb_blobs(as_git_repository(repo))
as_git_repository <- function(x = ".") {

  stopifnot(inherits(x, c("character", "rpath", "grepo", "git_repository")))

  if (inherits(x, "git_repository"))
    return(invisible(x))

  if (inherits(x, "grepo"))
    x <- x$path

  git2r::repository(as.character(as.rpath(x)))

}

