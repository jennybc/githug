#' Stage changes for the next commit.
#'
#' Stage changes to files in preparation for a commit. In an interactive
#' session, you'll get the chance to "just stage everything: Y/N?", if you
#' haven't pre-staged or specified any paths. To pre-authorize the staging of
#' all current file additions, deletions, and modifications, use
#' \code{git_commit(all = TRUE)}.
#'
#' \code{git_add()} and \code{git_stage()} are aliases for each other, so use
#' what feels most natural, i.e. "add" a file to the repo and "stage"
#' modifications. These are convenience wrappers around
#' \code{\link[git2r:add]{git2r::add}()}.
#'
#' @param ... One or more paths or shell glob patterns that will be matched
#'   against files in the repo's working directory. Paths that match will be
#'   added to the set of changes staged for the next commit.
#' @param all Logical, consulted if no paths are given. If \code{TRUE},
#'   pre-authorizes the staging of all new files, file deletions, and file
#'   modifications. Emulates \code{git add -A}, which is equivalent to \code{git
#'   add .; git add -u}.
#' @param force Logical, defaults to \code{FALSE}. Value \code{TRUE} is required
#'   if any of the to-be-staged paths are currently ignored.
#' @template repo
#' @return nothing
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' write("You get what you settle for.", "louise.txt")
#' git_status()
#' ## try this interactively and accept the proposed auto-staging
#' # git_add()
#' git_add("max.txt", "louise.txt")
#' git_status()
#' write("If done properly armed robbery doesn't have to be a totally unpleasant experience.",
#'       "jd.txt")
#' write("Is he your husband or your father?", "louise.txt", append = TRUE)
#' git_status()
#' git_stage(all = TRUE)
#' git_status()
#' git_commit(message = "Brains'll only get you so far and luck always runs out.")
#' git_status()
#' setwd(owd)
#' @export
git_stage <- function(..., all = FALSE, force = FALSE, repo = ".") {
  path <- as.character(c(...))
  stopifnot(is_lol(all))
  stopifnot(is_lol(force))
  gr <- as.git_repository(repo)

  status_before <- git_status_check(repo = repo, ls = force)
  stageable <- c("unstaged", "untracked", if (force) "ignored")
  stageable_before <- status_before$status %in% stageable

  n_path <- length(path)
  n_stageable <- sum(stageable_before)

  if (sum(n_path + n_stageable) == 0L) {
    message("No changes to stage.")
    return(invisible())
  }

  printed <- FALSE

  if (n_path == 0L && missing(all)) {
    if (!interactive()) {
      message("Either provide paths to stage or authorize auto-staging with ",
              "`all = TRUE`.\nNothing staged.")
      return(invisible())
    }
    staged <- status_before$status == "staged"
    if (sum(staged) > 0) {
      message("Already staged for next commit:")
      print(status_before[staged, ])
      message("")
    }
    message("Unstaged additions, deletions, and modifications:")
    print(status_before[stageable_before, ])
    printed <- TRUE
    all <- yesno("\nStage all of this?")
  }

  if (n_path == 0L) {
    if (all) {
      path <- status_before$path[stageable_before]
    } else {
      message("No changes staged.")
      return(invisible())
    }
  }

  git2r::add(repo = gr, path = path, force = force)

  status_after <- git_status_check(repo = repo, ls = force)
  stageable_after <- status_after$status %in% stageable
  staged_actual <- setdiff(status_before$path[stageable_before],
                           status_after$path[stageable_after])
  uhoh <- setdiff(path, staged_actual)
  if (length(uhoh) > 0) {
    message(
      "These requested paths may not have been staged:\n",
      paste("  *", uhoh, collapse = "\n"),
      "\nMaybe there were no stageable changes?",
      "\nOr these paths don't exist in this repo?",
      "\nIf trying to stage ignored files, use 'force = TRUE'.",
      "\nFinal caveat: Expect false positives if 'path' contained shell globs."
    )
  }

  n_staged <- length(staged_actual)
  if (n_staged > 0) {
    if (printed) {
      message("Staged ", n_staged, " path(s).")
    } else {
      message("Staged these paths:\n",
              paste("  *", staged_actual, collapse = "\n"))
    }
  }

  return(invisible())
}

#' @rdname git_stage
#' @export
git_add <- git_stage
