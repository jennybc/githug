#' Open a Git repository, the git2r way
#'
#' Use this to convert a path into a \code{\linkS4class{git_repository}} object,
#' which is how the \code{\link{git2r}} package handles Git repositories. This
#' function is a slightly more flexible version of
#' \code{\link[git2r:repository]{git2r::repository}()}.
#'
#' \code{githug} uses \code{\link{git2r}}, under the hood, to perform local Git
#' operations. While \code{githug} always identifies the repository via its
#' path, \code{\link{git2r}} handles repositories as objects of class
#' \code{\linkS4class{git_repository}}. If you want to do a Git operation that
#' isn't exposed via \code{githug}, this function helps you specify the
#' repository \code{\link{git2r}}-style.
#'
#' @param x path that is or is in a Git repository; defaults to working
#'   directory
#' @param ... additional arguments, such as \code{ceiling} from
#'   \code{\link[git2r]{discover_repository}()}
#'
#' @return An S4 \code{\linkS4class{git_repository}} object
#'
#' @examples
#' \dontrun{
#' as.git_repository()
#' as.git_repository("path")
#' as.git_repository("repo-path/subdir")
#' as.git_repository("repo-path/subdir", ceiling = 0)
#'
#' ## here's a rather exotic Git operation that githug is unlikely to expose:
#' ## odb_blobs() lists "all blobs reachable from the commits in the object database"
#' ## pre-process the repo with as_git_repository() to prepare for git2r
#' git2r::odb_blobs(as.git_repository("repo-path"))
#' }
#' @export
as.git_repository <- function(x, ...) UseMethod("as.git_repository")

#' @export
as.git_repository.character <- function(x, ...) {
  git2r::repository(find_repo_path(x, ...))
}

#' @export
as.git_repository.NULL <- function(x, ...) as.git_repository(x = ".", ...)



find_repo_path <- function(x = ".", ...) {

  if (!dir_exists(x)) {
    stop("directory does not exist:\n", x, call. = FALSE)
  }

  ## why not use repository(..., discover = TRUE) on x?
  ## because it errors if can't discover repo
  ## whereas discover_repository() returns NULL
  ## also repository() silently ignores ceiling, which might be in ...
  xrepo <- git2r::discover_repository(x, ...)

  if (is.null(xrepo)) {
    stop("no git repo exists here:\n", x, call. = FALSE)
  }

  gr_path(git2r::repository(xrepo, discover = TRUE))

}

is_in_repo <- function(x = ".", ...) {
  dir_exists(x) && !is.null(git2r::discover_repository(x, ...))
}

is_a_repo <- function(x = ".") is_in_repo(x, ceiling = 0)

gr_path <- function(gr) {
  stopifnot(inherits(gr, "git_repository"))
  normalize_path_strict(git2r::workdir(gr))
}
