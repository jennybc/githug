#' Create a new branch
#'
#' Create a new local branch. You must specify the \code{name} of the new
#' branch, at the very least. By default, the new branch will point at current
#' HEAD. Optionally, you can specify another commit to base the branch on, via
#' its SHA.
#'
#' Convenience wrapper around
#' \code{\link[git2r:branch_create]{git2r::branch_create}()}.
#'
#' @param name Name for the new branch
#' @template repo
#' @param sha The SHA of a commit in \code{repo}
#'
#' @examples
#' repo <- git_init(tempfile("githug-branches-"))
#' owd <- setwd(repo)
#'
#' ## first commit
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_commit("nowhere.txt", message = "1: not in the middle of nowhere")
#' git_branch_list()
#'
#' ## second commit
#' write("but we can see it from here.", "nowhere.txt", append = TRUE)
#' git_commit("nowhere.txt", message = "2: but we can see it from here")
#'
#' ## create new branch that points at HEAD = second commit
#' git_branch_create("carpe_diem")
#' git_branch_list()
#'
#' ## create new branch that points at *first commit*, via its SHA
#' (gl <- git_log())
#' git_branch_create("hindsight", sha = gl$sha[[2]])
#' git_branch_list()
#'
#' \dontrun{
#' ## try to re-create an existing branch and fail
#' git_branch_create("hindsight")
#' }
#'
#' setwd(owd)
#' @export
git_branch_create <- function(name, repo = ".", sha = character()) {

  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is.character(sha), length(sha) <= 1)
  gr <- as.git_repository(repo)

  if (length(sha) == 1L) {
    gco <- git2r::lookup(gr, sha)
    stop_msg <-
      sprintf("Can't find a commit with this SHA:\n%s\nin this repository:\n%s",
              sha, git2r::workdir(gr))
  } else {
    gco <- git2r::revparse_single(gr, "HEAD")
    stop_msg <-
      paste0("Can't find a commit to use as base of new branch.\n",
             "Use git_log() to see previous commits.\n",
             "Maybe there aren't any?")
  }

  if (!git2r::is_commit(gco)) {
    stop(stop_msg, call. = FALSE)
  }

  ## I'm intentionally not exposing 'force'
  gb <- git2r::branch_create(commit = gco, name = name, force = FALSE)
  if (!git2r::is_branch(gb)) {
    stop("Could not create new branch '", name,"' pointed at:\n", sha,
         call. = FALSE)
  }

  gco <- git_branch_tip_commit(gb)
  message("New branch '", name, "' pointed at:\n", bulletize_git_commit(gco))
  invisible(sha_with_hint(gco))

}
