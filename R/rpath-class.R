## goal: insulate user from the git2r S4 git_repository class + methods
## instead, we're always going to identify the repo via its path
##
## S3 class here:

## rpath: path to working directory of a git repo = parent dir of .git

## I'm targetting interactive use, so not worrying about bare repos

## I never actually create any objects with class rpath, so just used for method
## dispatch ... is that silly?

## review of most relevant git2r functions
## discover_repository():
##  * input = path like ~/foo ~/foo/ ~/foo.git ~/foo.git/
##  * output = path like ~/foo/.git/ <-- note the terminating file separator
##  * discover_repository() will walk up parents unless 'ceiling' is 0 or 1
## repository():
##  * input = path like ~/foo ~/foo/ ~/foo.git ~/foo.git/
##  * output = git_repository S4 object
##  * init() also returns these
##  * repository() will walk up parents iff discover = TRUE (should probably
##    be re-thought now that we have ceiling arg in discover_repository?)
## workdir():
##  * input = git_repository S4 object
##  * output = path like ~/foo/  <-- note the terminating file separator
##  * note: returns NULL if bare repo, which I don't address

## rpath ------------------------------------------

## what could ... possibly be? the ceiliing argument for
## git2r::discover_repository()
as.rpath <- function(x, ...) UseMethod("as.rpath")

as.rpath.rpath <- function(x, ...) x

as.rpath.NULL <- function(x, ...) NULL

as.rpath.git_repository <- function(x, ...) as.rpath(git2r::workdir(x))

as.rpath.character <- function(x, ...,
                               raise = stop,
                               msg = "no %s exists here:\n%s") {

  stopifnot(length(x) == 1L)
  x <- normalizePath(x, mustWork = FALSE)

  if (!file.exists(x)) {
    if (!is.null(raise)) {
      do.call(raise, list(sprintf(msg, "path", x), call. = FALSE))
    }
    return(invisible(NULL))
  }

  ## specify 'ceiling' via ... if you wish
  xrepo <- git2r::discover_repository(x, ...)

  if (is.null(xrepo)) {
    if (!is.null(raise)) {
      do.call(raise, list(sprintf(msg, "git repo", x), call. = FALSE))
    }
    return(invisible(NULL))
  }

  ## why not use repository(..., discover = TRUE) directly on x?
  ## because it errors if can't discover repo, so would require try() anyway
  normalizePath(git2r::workdir(git2r::repository(xrepo, discover = TRUE)))

}

rpath <- function(x = NULL, ...) {
  stopifnot(is.null(x) || (length(x) == 1L && inherits(x, "character")))
  as.rpath(x, ...)
}

is_in_repo <- function(x, ...) !is.null(as.rpath(x, ..., raise = NULL))

is_a_repo <- function(x) is_in_repo(x, ceiling = 0)

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
#'   \code{rpath} (S3 class used only internally in \code{\link{githug}}) or of
#'   class \code{\linkS4class{git_repository}} (from the \code{\link{git2r}}
#'   package).
#'
#' @return An S4 \code{\linkS4class{git_repository}} object
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("githug-to-git2r-example-"))
#' owd <- setwd(repo)
#' git_config(user.name = "jd", user.email = "jd@example.org")
#' writeLines(paste("Well, I've always believed that if done properly, armed",
#'                  "robbery doesn't have to be an unpleasant experience."),
#'            "jd.txt")
#' git_add("jd.txt")
#' git_commit("jd is a smooth talker")
#'
#' ## here's a rather exotic Git operation that githug is unlikely to expose:
#' ## odb_blobs() lists "all blobs reachable from the commits in the object database"
#' ## pre-process the repo with as_git_repository() to prepare for git2r
#' git2r::odb_blobs(as_git_repository())
#' setwd(owd)
as_git_repository <- function(x = ".") {

  stopifnot(inherits(x, c("character", "rpath", "git_repository")))

  if (inherits(x, "git_repository"))
    return(invisible(x))

  git2r::repository(as.rpath(x))

}

