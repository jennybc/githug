#' Switch to another branch
#'
#' Switch to or "checkout" another branch. Optionally, create the branch if it
#' doesn't exist yet and then check it out. If you currently have uncommitted
#' changes, it is possible to lose those changes when you switch to another
#' branch. \code{git_switch()} will never let that happen. If that's really what
#' you want, call the lower-level function \code{git_branch_checkout(..., force
#' = TRUE)}.
#'
#' Convenience wrappers around \code{\link{git2r}}'s
#' \code{\link[git2r]{checkout,git_branch-method}}.
#'
#' @param name Name of the branch
#' @param create Whether to create the branch if it does not exist yet
#' @param force Whether to overwrite current files with the versions in branch
#'   \code{name}, even if this means discarding uncommited changes. Default is
#'   \code{FALSE}.
#' @template repo
#'
#' @name githug-switch
#' @aliases git_switch git_branch_checkout
#' @examples
#' repo <- git_init(tempfile("githug-branches-"))
#' owd <- setwd(repo)
#'
#' ## first commit
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_commit("nowhere.txt", message = "1: not in the middle of nowhere")
#' git_branch_list()
#'
#' \dontrun{
#' ## in an interactive session, try this to checkout and create at once
#' git_switch("louise")
#' }
#'
#' git_branch_checkout("louise", create = TRUE)
#' git_branch_current()
#'
#' setwd(owd)
NULL

#' @section git_switch:
#'
#'   Designed for interactive use. Request a branch by \code{name} or, by
#'   default, switch to \code{master}. If the branch doesn't exist yet, you'll
#'   get an offer to create it and immediately check it out.
#'
#'   \code{git_switch()} will not let you switch branches if you have
#'   uncommitted changes that would be lost. You should either:
#'
#'   \enumerate{
#'   \item Commit or stash these changes. Then call \code{git_switch()} again.
#'   \item Use \code{git_branch_checkout()} directly, with \code{force =  TRUE},
#'   if you are willing to lose these changes.
#'   }
#'
#' @rdname githug-switch
#' @export
git_switch <- function(name = "master", create = NA, repo = ".") {
  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is_lol(create))
  gb <- git_branch_from_name(name, repo)

  if (is.null(gb) && is.na(create)) {
    message("'", name, "' is not the name of any existing local branch.\n")
    create <- FALSE
    if (interactive()) {
      create <- yesno("Would you like to create it, then check it out?")
    }
    if (!create) {
      stop("Aborting.", call. = FALSE)
    }
  }

  git_branch_checkout(name = name, create = create, force = FALSE, repo = repo)

}

#' @section git_branch_checkout:
#'
#'   Designed for non-interactive use. If the branch doesn't exist yet, you'll
#'   have to explicitly authorize its creation via \code{create = TRUE}.
#'   \code{force = TRUE} will checkout branch \code{name} even if it means
#'   losing uncommitted changes. In the future, githug will make a branch and a
#'   commit or a stash behind the scenes here, in case you later have regrets.
#'
#' @rdname githug-switch
#' @export
git_branch_checkout <- function(name = "master", create = FALSE,
                                force = FALSE, repo = ".") {
  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is_lol(create))
  stopifnot(is_lol(force))
  gb <- git_branch_from_name(name, repo)
  gr <- as.git_repository(repo)

  if (is.null(gb) && !create) {
    stop("'", name, "' is not the name of any existing local branch.\n",
         "Aborting.", call. = FALSE)
  }

  ## TO DO: if 'force = TRUE', make the safety branch or stash RIGHT HERE

  git2r::checkout(object = gr, branch = name, create = create, force = force)

  current_branch <- git_branch_current(repo = repo)
  message("Switched to branch:\n  * ", current_branch)
  invisible(current_branch)
}

