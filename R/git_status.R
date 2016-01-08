#' Display status of a Git repo
#'
#' Display differences between current state of files in a repo and their state
#' at the last commit.
#'
#' @inheritParams git2r::status
#' @param ... Additional arguments to \code{\link[git2r]{status}} from
#'   \code{\link{git2r}}
#' @template repo
#'
#' @return A list with named components "Untracked files", "Staged changes",
#'   "Unstaged changes", with S3 class \code{git_status}.
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' writeLines("Change me", "change-me")
#' writeLines("Delete me", "delete-me")
#' git_status()
#' git_COMMIT("first commit")
#' git_status()
#' write("OK", "change-me", append = TRUE)
#' file.remove("delete-me")
#' writeLines("Add me", "add-me")
#' git_COMMIT("second commit")
#' git_status()
#' setwd(owd)
git_status <- function(repo = ".", ...) {

  repo <- as.rpath(repo, raise = warning)
  if (is.null(repo)) {
    return(invisible(NULL))
  }
  gr <- as_git_repository(as.rpath(repo))
  s <- git2r::status(repo = gr, ...)
  structure(s, class = c("git_status", "list"))
  #message_nl(capture.output(show(s)))
  #invisible(as.rpath(gr))
}
