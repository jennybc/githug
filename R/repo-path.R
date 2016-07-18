#' Open a Git repository, the git2r way
#'
#' \code{githug} uses the \code{\link{git2r}} package, under the hood, to
#' perform local Git operations. \code{\link{git2r}} handles Git repos as
#' objects of class \code{\linkS4class{git_repository}}. This function provides
#' a more flexible version of \code{\link[git2r]{repository}()}, which converts a
#' path to a \code{\linkS4class{git_repository}}. You might need this for more
#' exotic Git operations, i.e. to call \code{\link{git2r}} functions that aren't
#' exposed via \code{githug}.
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

  if (!path_exists(x)) {
    stop("path does not exist:\n", x, call. = FALSE)
  }

  ## why not use repository(..., discover = TRUE) on x?
  ## because it errors if can't discover repo
  ## whereas discover_repository() returns NULL
  ## also repository() silently ignores ceiling, which might be in ...
  xrepo <- git2r::discover_repository(x, ...)

  if (is.null(xrepo)) {
    stop("no git repo exists here:\n", x, call. = FALSE)
  }

  normalizePath(git2r::workdir(git2r::repository(xrepo, discover = TRUE)),
                winslash = "/")

}

is_in_repo <- function(x, ...) {
  path_exists(x) && !is.null(git2r::discover_repository(x, ...))
}

is_a_repo <- function(x) is_in_repo(x, ceiling = 0)
