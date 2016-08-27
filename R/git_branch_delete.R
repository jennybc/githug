#' Delete a branch
#'
#' Delete an existing local branch. You won't be allowed to delete the branch
#' you're on. Switch to another branch, then delete.
#'
#' Convenience wrapper around
#' \code{\link[git2r:branch_delete]{git2r::branch_delete}()}.
#'
#' @param name Name of the branch
#' @template repo
#'
#' @examples
#' repo <- git_init(tempfile("githug-branches-"))
#' owd <- setwd(repo)
#'
#' ## commit so that master branch exists
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_commit("nowhere.txt", message = "... but we can see it from here.")
#'
#' ## create a branch off of master
#' git_branch_create("doomed")
#' git_branch_list()
#'
#' ## switch to doomed branch
#' git_switch("doomed")
#' git_branch()
#'
#' \dontrun{
#' ## try -- and fail -- to delete doomed branch
#' git_branch_delete("doomed")
#' }
#'
#' ## switch back to master
#' git_switch()
#'
#' ## delete the new branch
#' git_branch_delete("doomed")
#' git_branch_list()
#'
#' setwd(owd)
#' @export
git_branch_delete <- function(name, repo = ".") {
  stopifnot(is.character(name), length(name) == 1L)

  gb <- git_branch_from_name(name = name, repo = repo)
  if (!git2r::is_branch(gb)) {
    stop("No existing local branch named '", name, "' found in this repo:\n",
         git2r::workdir(as.git_repository(repo)), call. = FALSE)
  }

  git2r::branch_delete(gb)
  message("Branch deleted:\n  * ", name)
  invisible()
}
