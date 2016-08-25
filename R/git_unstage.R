#' Unstage changes for the next commit.
#'
#' Remove file modifications from the staging area for the next commit, BUT
#' LEAVE YOUR FILES ALONE. This function is "working directory safe". It will
#' not change your files. It only unstages them. When would you use this? If
#' you've staged changes by mistake and you don't want them in the next commit
#' after all.
#'
#' \code{git_unstage()} addresses a popular question on StackOverflow:
#' \href{http://stackoverflow.com/questions/348170/how-to-undo-git-add-before-commit}{How
#' to undo 'git add' before commit?}, with over 1.3 million views.  In terms of
#' command line Git, this reverses \code{git add file.txt}. The call
#' \code{git_unstage("file.txt")} is equivalent to \code{git reset file.txt},
#' which is short for \code{git reset --mixed HEAD file.txt}, i.e. a mixed reset
#' of \code{file.txt} to the commit pointed to by current HEAD.
#'
#' @param ... One or more paths that will be matched against files with changes
#'   that are staged for the next commit. Paths that match will be unstaged,
#'   i.e. their changes will not be part of the next commit.
#' @param all Logical, consulted if no paths are given. If \code{TRUE},
#'   pre-authorizes the unstaging of all staged files.
#' @template repo
#'
#' @return nothing
#' @export
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' git_commit(all = TRUE, message = "first commit")
#' write("You get what you settle for.", "louise.txt")
#' git_status()
#' git_add("louise.txt")
#' git_status()
#' git_unstage("louise.txt")
#' git_status()
#' setwd(owd)
git_unstage <- function(..., all = FALSE, repo = ".") {
  path <- as.character(c(...))
  stopifnot(is_lol(all))
  gr <- as.git_repository(repo)

  status_before <- git_status_check(repo = repo)
  staged_before <- status_before$status == "staged"
  n_staged_before <- sum(staged_before)

  if (n_staged_before == 0L) {
    message("Nothing to unstage.")
    return(invisible())
  }

  printed <- FALSE
  n_path <- length(path)

  if (n_path == 0L && missing(all)) {
    if (!interactive()) {
      message("Either provide paths to unstage or authorize auto-unstaging ",
              "with `all = TRUE`.\nNothing unstaged.")
      return(invisible())
    }
    message("Currently staged for next commit:")
    print(status_before[staged_before, ])
    printed <- TRUE
    all <- yesno("\nUnstage all of this?")
  }

  staged <- status_before$path[staged_before]

  if (n_path == 0L) {
    if (all) {
      path <- staged
    } else {
      message("Nothing unstaged.")
      return(invisible())
    }
  }

  git2r::reset(gr, path)

  status_after <- git_status_check(repo = repo)
  staged_after <- status_after$status == "staged"
  unstaged_actual <- setdiff(staged, status_after$path[staged_after])
  uhoh <- setdiff(path, unstaged_actual)
  if (length(uhoh) > 0) {
    message(
      "These requested paths may not have been unstaged:\n",
      paste("  *", uhoh, collapse = "\n"),
      "\nMaybe these paths were not staged to begin with?",
      "\nOr don't exist in this repo?",
      "\nAlso remember shell globs are not allowed for unstaging."
    )
  }

  n_unstaged <- length(unstaged_actual)
  if (n_unstaged > 0) {
    if (printed) {
      message("Unstaged ", n_unstaged, " path(s).")
    } else {
      message("Unstaged these paths:\n",
              paste("  *", unstaged_actual, collapse = "\n"))
    }
  }

  return(invisible())
}
