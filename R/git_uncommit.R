#' Undo a Git commit but leave files alone
#'
#' Make it as if the last Git commit never happened BUT LEAVE YOUR FILES ALONE.
#' This function is "working directory safe" but "history unsafe". Think twice
#' before uncommitting a commit that you have pushed (see Details).
#'
#' \code{git_uncommit()} will not change your files. It just reverses the act of
#' making the most recent Git commit. Even the staged / unstaged status of your
#' modifications is preserved. When might you use this? To undo the last commit
#' and stage a few more changes to your files and/or retry your commit, but with
#' a better message.
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
#' git_log()       ## see? 2 commits
#' git_status()    ## see? nothing to stage
#' git_uncommit()  ## roll back most recent commit
#' git_log()       ## see? only 1st commit is in history
#' git_status()    ## see? jimmy.txt is a new, staged file
#' ## re-do that 2nd commit but with message in ALL CAPS
#' git_commit(message = "THAT'S THE CODE WORD. I MISS YOU, PEACHES.")
#' git_log()       ## see? back to 2 commits
#' setwd(owd)
#' @export
git_uncommit <- function(repo = ".") {
  gr <- as.git_repository(repo)

  ## TO WORRY: what if HEAD is detached?

  current_head <- git2r::revparse_single(gr, "HEAD")
  stopifnot(git2r::is_commit(current_head))
  message("Uncommit:\n", bulletize_git_commit(current_head))

  new_head <- git2r::revparse_single(gr, "HEAD^")
  stopifnot(git2r::is_commit(new_head))
  git2r::reset(new_head, reset_type = "soft")

  message("HEAD now points to (but no files were changed!):\n",
          bulletize_git_commit(new_head))
  invisible(sha_with_hint(new_head))
}
