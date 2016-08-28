#' Rename a branch
#'
#' Rename an existing local branch. It's fine to rename the branch you're on.
#'
#' Convenience wrapper around
#' \code{\link[git2r:branch_create]{git2r::branch_rename}()}.
#'
#' @param from Name of the existing branch
#' @param to New name for the branch
#' @template repo
#'
#' @examples
#' repo <- git_init(tempfile("githug-branches-"))
#' owd <- setwd(repo)
#'
#' ## commit so that master branch exists
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_commit("nowhere.txt", message = "... but we can see it from here.")
#' git_branch_list()
#'
#' ## rename master
#' git_branch_rename("master", "louise")
#' git_branch_list()
#'
#' setwd(owd)
#' @export
git_branch_rename <- function(from, to, repo = ".") {
  stopifnot(is.character(from), length(from) == 1L)
  stopifnot(is.character(to), length(to) == 1L)

  from_branch <- git_branch_from_name(name = from, repo = repo)
  if (!git2r::is_branch(from_branch)) {
    stop("No existing local branch named '", from, "' found in this repo:\n",
         repo_path(repo), call. = FALSE)
  }

  ## I'm intentionally not exposing 'force'
  to_branch <- git2r::branch_rename(from_branch, name = to, force = FALSE)
  if (!git2r::is_branch(to_branch)) {
    stop("Could not rename branch '", from, "' to '", to, "'.", call. = FALSE)
  }

  message("Branch renamed:\n  * ", from_branch@name, " --> ", to_branch@name)
  invisible(git_revision_sha(to_branch@name, repo = repo))
}
