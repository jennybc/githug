#' Re-do the most recent commit
#'
#' Undo the most recent commit WHILE LEAVING ALL YOUR FILES ALONE, combine those
#' changes with the currently staged changes, and make a new commit. If nothing
#' is currently staged, this is just a way to edit the most recent commit
#' message. This function is "working directory safe" but "history unsafe".
#' Think twice before "amending" a commit that you have pushed (see Details).
#'
#' \code{git_amend()} will not change your files. It gives you a do over on your
#' most recent Git commit. When might you use this? If you realize the most
#' recent commit included the wrong file changes or had a bad commit message. If
#' you're not ready to re-commit yet, use \code{\link{git_uncommit}()} to just
#' undo the commit.
#'
#' When might you NOT want to use this? If you have already pushed the most
#' recent commit to a remote. It could still be OK if you're sure no one else
#' has pulled. But be prepared to force push in this situation.
#'
#' \code{git_amend()} addresses the fourth most up-voted question on
#' StackOverflow:
#' \href{http://stackoverflow.com/questions/179123/edit-an-incorrect-commit-message-in-git}{Edit
#' an incorrect commit message in Git}, with over 1.7 million views. It is
#' equivalent to \code{git commit --amend -m "New commit message"}.
#'
#' @param message The commit message. If not provided and \code{ask = FALSE},
#'   the original commit message is reused. If message is not given and
#'   \code{ask = TRUE} and session is interactive, you get a chance to supply
#'   the message, including an option to reuse the original message.
#' @param ask Whether to confirm that user wants to change history
#' @template repo
#'
#' @template return-SHA-with-hint
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' git_commit("max.txt", message = "lines from max")
#' write("Did I hear somebody say \"Peaches\"?", "jimmy.txt")
#' git_commit("jimmy.txt", message = "lines from some guy")
#' git_history()   ## note the SHA of the most recent commit
#'
#' ## fix the previous commit message
#' git_amend(message = "lines from jimmy", ask = FALSE)
#' git_history()   ## note the SHA of most recent commit has changed
#'
#' setwd(owd)
git_amend <- function(message = character(), ask = TRUE, repo = ".") {
  stopifnot(is.character(message), length(message) <= 1)
  gr <- as.git_repository(repo)
  stopifnot(is_lol(ask))
  just_do_it <- isFALSE(ask)

  ## TO DO: describe if/how staging area differs from HEAD

  head_commit <- git_HEAD(repo = repo)
  message_before <- head_commit@message
  ## temporary measure: abort now if HEAD^ doesn't exist
  ## https://github.com/jennybc/githug0/issues/32
  git_HEAD_parent(repo = repo)

  if (is_not_FALSE(ask)) {
    message("Warning: changing history!\n\n",
            "git_amend() actually removes a commit from the history\n",
            "  and then adds a new one.\n",
            "If you've already pushed to a remote,\n",
            "  especially if others have already pulled,\n",
            "    this will cause problems.")
    if (interactive()) {
       just_do_it <- yesno("\nDo you still want to git_amend()?")
    } else {
      message("\nYou must explicitly authorize this with 'ask = FALSE'.")
    }
  }
  if (!just_do_it) {
    message("Aborting.")
    return(invisible())
  }

  if (no_string(message)) {
    if (isFALSE(ask)) {
      message <- message_before
    } else if (interactive()) {
      message("Here is the previous commit message:\n", message_before)
      keep_message <- yesno("Do you want to use it again?\n",
                            yes = "yes, use again",
                            no = "no, let me enter a new message")
      if (keep_message) {
        message <- message_before
      } else {
        message <- get_user_input("Enter new commit message (ESC to abort)")
      }
    }
  }
  ## git2r::commit() will error if no message, but I don't want to uncommit if I
  ## can already tell the new commit won't succeed
  if (no_string(message)) {
    stop("Commit message is required. Aborting.")
  }

  gco <- git_uncommit_do(repo = repo)
  gco <- git2r::commit(repo = gr, message = message)
  sha <- sha_with_hint(gco)
  message("Commit:\n", bulletize_sha(sha))
  invisible(sha)
}
