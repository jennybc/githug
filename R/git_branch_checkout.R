#' Switch to another branch
#'
#' Switch to or "checkout" another branch. Optionally, create the branch if it
#' doesn't exist yet and then check it out.
#'
#' If you currently have uncommitted changes, it is possible -- though not
#' inevitable -- to lose those changes when you switch to another branch.
#' \code{git_switch()} will never let that happen. You should seriously consider
#' committing or stashing those at-risk changes. However, if you really want to
#' nuke them, call the lower-level function \code{git_branch_checkout(..., force
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
#' @template rev
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
git_switch <- function(name = character(), create = NA, repo = ".", rev = "HEAD") {
  stopifnot(is.character(name), length(name) <= 1L)
  stopifnot(is_lol(create))

  if (length(name) == 0L) {     ## we are switching branch, not creating one
                                ## but we don't know which one
                                ## try to justify switch to master
    suppressMessages(current_branch <- git_branch_current(repo = repo))
    master_exists <- git_revision_exists("master", repo = repo)
    if (master_exists && current_branch != "master") {
      name <- "master"
    }
  }
  if (length(name) == 0L) {     ## we are switching branch, not creating one
                                ## but we don't know which one
                                ## and can't just switch to master
    if (!interactive()) {
      stop("Specify the target branch by name.", call. = FALSE)
    }
    gbl <- git_branch_list(where = "local", repo = repo)
    gbl <- gbl[!gbl$HEAD, ]
    if (nrow(gbl) == 0L) {
      stop("Can't find a local branch to switch to.", call. = FALSE)
    }
    i <- 0L
    i <- utils::menu(gbl$branch, title = "Pick a branch.\nEnter 0 to exit.")
    if (i == 0L) {
      stop("Aborting.", call. = FALSE)
    }
    name <- gbl$branch[i]
  }
  ## we have a branch name now

  gb <- git_branch_from_name(name, repo)

  if (is.null(gb)) {            ## branch does not exist
    message("'", name, "' is not the name of any existing local branch.\n")
    if (is.na(create)) {        ## not pre-authorized to create it
      if (!interactive()) {
        stop("\nAuthorize its creation with 'create = TRUE'.", call. = FALSE)
      }
      create <- FALSE
      create <- yesno("Would you like to create it, then check it out?")
    }                           ## create is either TRUE or FALSE now
    if (!create) {
      stop("Aborting.", call. = FALSE)
    }
  }

  git_branch_checkout(name = name, create = create, force = FALSE,
                      repo = repo, rev = rev)

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
                                force = FALSE, repo = ".", rev = "HEAD") {
  stopifnot(is.character(name), length(name) == 1L)
  stopifnot(is_lol(create), is_lol(force))
  gb <- git_branch_from_name(name, repo)

  if (is.null(gb) && is_not_TRUE(create)) {
    stop("'", name, "' is not the name of any existing local branch.\n",
         "Aborting.", call. = FALSE)
  }

  ## TO DO: if 'force = TRUE', make the safety branch or stash RIGHT HERE

  if (is.null(gb) && isTRUE(create)) {
    git_branch_create(name = name, repo = repo, rev = rev)
  }

  git2r::checkout(as.git_repository(repo), branch = name,
                  create = FALSE, force = force)

  current_branch <- git_branch_current(repo = repo)
  message("Switched to branch:\n  * ", current_branch)
  invisible(current_branch)
}

