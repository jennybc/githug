#' Undo a Git commit but leave files alone
#'
#' Make it as if the last Git commit never happened BUT LEAVE YOUR FILES ALONE.
#' This function is "working directory safe" but "history unsafe". Think twice
#' before uncommitting a commit that you have pushed (see Details).
#'
#' \code{git_uncommit()} will not change your files. It just reverses the act of
#' making the most recent Git commit. Even the staged / unstaged status of your
#' modifications is preserved. When might you use this? To undo the last commit
#' so you can stage different changes or files and/or redo your commit, but with
#' a better message. Note that \code{\link{git_amend}()} might be a more
#' efficient way to do that.
#'
#' When might you NOT want to use this? If you have already pushed the most
#' recent commit to a remote. It could still be OK if you're sure no one else
#' has pulled. But be prepared to force push in this situation.
#'
#' \code{git_uncommit()} addresses the second most up-voted question on
#' StackOverflow:
#' \href{http://stackoverflow.com/questions/927358/how-to-undo-last-commits-in-git}{How
#' to undo last commit(s) in Git?}, with over 3.6 million views. It is
#' equivalent to \code{git reset --soft HEAD^}, i.e. a soft reset to the commit
#' that is parent to the commit pointed to by current HEAD.
#'
#' @param ask Whether to confirm that user wants to change history
#' @template repo
#' @template return-SHA-with-hint
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' git_commit("max.txt",
#'            message = "Brains'll only get you so far and luck always runs out.")
#' write("Did I hear somebody say \"Peaches\"?", "jimmy.txt")
#' git_commit("jimmy.txt", message = "That's the code word. I miss you, Peaches.")
#' git_history()   ## see? 2 commits
#' git_status()    ## see? nothing to stage
#' git_uncommit()  ## roll back most recent commit
#' git_history()   ## see? only 1st commit is in history
#' git_status()    ## see? jimmy.txt is a new, staged file
#' ## re-do that 2nd commit but with message in ALL CAPS
#' git_commit(message = "THAT'S THE CODE WORD. I MISS YOU, PEACHES.")
#' git_history()   ## see? back to 2 commits
#' setwd(owd)
#' @export
git_uncommit <- function(ask = TRUE, repo = ".") {
  stopifnot(is_lol(ask))
  just_do_it <- isFALSE(ask)

  ## TO WORRY: what if HEAD is detached?

  git_HEAD(repo = repo)
  ## temporary measure: abort now if HEAD^ doesn't exist
  ## https://github.com/jennybc/githug0/issues/32
  git_HEAD_parent(repo = repo)

  ## TO DO: once I can check status of remote tracking branch, refine this.
  if (is_not_FALSE(ask)) {
    message("Warning: changing history!\n\n",
            "git_uncommit() leaves your files intact,\n",
            "  but removes a commit from the history.\n",
            "If you've already pushed to a remote,\n",
            "  especially if others have already pulled,\n",
            "    this will cause problems.")
    if (interactive()) {
      just_do_it <- yesno("\nDo you still want to uncommit?")
    } else {
      message("\nYou must explicitly authorize this with 'ask = FALSE'.")
    }
  }

  if (!just_do_it) {
    message("Aborting.")
    return(invisible())
  }

  git_uncommit_do(repo = repo)

}

git_uncommit_do <- function(repo = ".") {

  current_head <- git_HEAD(repo = repo)
  message("Uncommit:\n", bulletize_git_commit(current_head))

  ## TO DO: make the safety branch or stash RIGHT HERE

  new_head <- git_rev_resolve(rev = "HEAD^", repo = repo)
  git2r::reset(new_head, reset_type = "soft")

  message("HEAD reset to:\n", bulletize_git_commit(new_head))
  invisible(sha_with_hint(new_head))

}
