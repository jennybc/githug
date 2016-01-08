#' Stage and commit files
#'
#' Stage files in preparation for a commit. And then commit them. Maybe even all
#' at once! Convenience wrappers around \code{\link[git2r]{add}},
#' \code{\link[git2r]{commit}}, and \code{\link[git2r]{status}} from
#' \code{\link{git2r}}.
#'
#' @inheritParams git2r::add
#' @inheritParams git2r::commit
#' @param ... Additional arguments to \code{\link[git2r]{add}} or
#'   \code{\link[git2r]{commit}} from \code{\link{git2r}}
#' @template repo
#' @name add-and-commit
#' @template return-repo-path
#' @examples
#' ## conventional git add, status, commit
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' writeLines("Are these girls real smart or real real lucky?", "max.txt")
#' git_add("max.txt")
#' git_status()
#' git_commit("Brains'll only get you so far and luck always runs out.")
#' git_status()
#' setwd(owd)
#'
#' if (require(dplyr)) {
#'   ## are pipes silly here? perhaps ...
#'   repo <- tempfile("githug-") %>%
#'     git_init()
#'   owd <- setwd(repo)
#'   writeLines("Are these girls real smart or real real lucky?", "max.txt")
#'   "max.txt" %>%
#'     git_add() %>%
#'     git_status()
#'   git_commit("Brains'll only get you so far and luck always runs out.") %>%
#'     git_status()
#'   setwd(owd)
#' }
#'
#' ## THE SHOUTY COMMANDS
#' repo <- git_init(tempfile("GITHUG-"))
#' owd <- setwd(repo)
#' writeLines("Change me", "change-me")
#' writeLines("Delete me", "delete-me")
#' git_status()
#' git_add(c("change-me", "delete-me"))
#' git_status()
#' git_commit("initial")
#' write("OK", "change-me", append = TRUE)
#' file.remove("delete-me")
#' writeLines("Add me", "add-me")
#' git_status()
#' git_ADD()
#' git_status()
#' ## TO DO: return here when commits and reset are wrapped
#' ccc <- git2r::commits()[[1]]
#' git2r::reset(ccc, "mixed")
#' git_status()
#' git_COMMIT("JUST DO IT.")
#' git_status()
#' setwd(owd)
NULL

#' @rdname add-and-commit
#'
#' @details \code{git_add} adds the current content of files identified via
#'   \code{path} to the index. They are slated for inclusion in the next commit.
#'
#' @export
git_add <- function(path, repo = ".", ...) {
  gr <- as_git_repository(as.rpath(repo))
  git2r::add(repo = gr, path = path, ...)
  invisible(as.rpath(gr))
}

#' @rdname add-and-commit
#'
#' @details \code{git_commit} stores the current contents of the index in a new
#'   commit along with a message describing the changes.
#'
#' @export
git_commit <- function(message = NULL, repo = ".", ...) {
  if (is.null(message))
    stop("you must provide a commit message", call. = FALSE)
  gr <- as_git_repository(as.rpath(repo))
  s <- unlist(git2r::status(repo = gr))
  if (!is.null(s)) {
    gco <- git2r::commit(repo = gr, message = message, ...)
    message_nl(capture.output(show(gco)))
  }
  invisible(as.rpath(gr))
}

#' @rdname add-and-commit
#'
#' @details \code{git_ADD} says "JUST STAGE ALL THE THINGS." Use this when you
#'   want the next commit to reflect all new files, file deletions, and file
#'   modifications in your repo. Similar to the automatic staging behavior of
#'   \href{https://git-scm.com/book/en/v2/Git-in-Other-Environments-Graphical-Interfaces}{workflow-oriented
#'    Git clients} like \href{https://desktop.github.com}{GitHub Desktop}. The
#'   intent is to emulate \code{git add -A}, which is equivalent to \code{git
#'   add .; git add -u}.
#'
#' @export
git_ADD <- function(repo = ".") {
  ##http://stackoverflow.com/questions/572549/difference-between-git-add-a-and-git-add
  gr <- as_git_repository(as.rpath(repo))
  s <- git2r::status(repo = gr)
  ## Untracked files + Staged changes + Unstaged changes
  s <- unlist(s)
  if (is.null(s)) {
    s <- ""
    message("nothing to ADD")
  }
  git2r::add(repo = gr, path = s)
  invisible(as.rpath(gr))
}

#' @rdname add-and-commit
#'
#' @details \code{git_COMMIT} says "JUST COMMIT ALL THE THINGS." Use this when
#'   you just want to commit the current state of your repo. It is
#'   \code{git_ADD} followed by \code{git_commit}. The intent is to emulate
#'   \code{git add -A && git commit}.
#'
#' @export
git_COMMIT <- function(message = NULL, repo = ".")
  ##http://stackoverflow.com/questions/2419249/git-commit-all-files-using-single-command
  git_commit(message = message, repo = git_ADD(repo))

