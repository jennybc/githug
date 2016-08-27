#' Create a new branch
#'
#' Create a new local branch. You must specify the \code{name} of the new
#' branch, at the very least. By default, the new branch will point at current
#' HEAD. Optionally, you can specify another commit to base the branch on, via a
#' \href{http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions}{revision
#' string}, e.g. \code{HEAD^}, \code{branchname}, \code{SHA-1} or a leading
#' substring thereof.
#'
#' Convenience wrapper around
#' \code{\link[git2r:branch_create]{git2r::branch_create}()}.
#'
#' @param name Name for the new branch
#' @template repo
#' @template rev
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
#' (gl <- git_history())
#' git_branch_create("hindsight", rev = gl$sha[[2]])
#' git_branch_list()
#'
#' \dontrun{
#' ## try to re-create an existing branch and fail
#' git_branch_create("hindsight")
#' }
#'
#' setwd(owd)
#' @export
git_branch_create <- function(name, repo = ".", rev = "HEAD") {

  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is.character(rev),  length(rev) == 1L)

  stop <- sprintf("rev '%s' doesn't resolve to a commit in this repo:\n%s",
                  rev, repo_path(repo))
  gco <- git_rev_gco(rev = rev, repo = repo, stop = stop)

  ## I'm intentionally not exposing 'force'
  gb <- git2r::branch_create(commit = gco, name = name, force = FALSE)
  if (!git2r::is_branch(gb)) {
    stop("Could not create new branch '", name,"' pointed at:\n",
         bulletize_gco(gco), call. = FALSE)
  }

  sha <- git_rev_sha(rev = gb@name, repo = repo)
  message("New branch '", name, "' pointed at:\n", bulletize_sha(sha))
  invisible(sha)

}
