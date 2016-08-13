#' ---
#' output:
#'   github_document:
#'     toc: true
#' ---

#+ setup
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
library(git2r)
devtools::session_info("git2r")$packages[1, ]
here <- rprojroot::find_package_root_file
devtools::load_all(here())

#' ## Verifying what happens with soft reset via `git2r::reset()`.
repo <- file.path("~", "tmp", "reset")

#' Clean up any previous work.
if (dir.exists(repo)) unlink(repo, recursive = TRUE)

#' Set up a repo.
repo <- git_init(repo)
gr <- as.git_repository(repo)

#' Check HEAD. Should be `NULL` before the first commit. Points to an "unborn
#' branch".
head(gr)

#' Create 2 files and commit them.
write("1 one 1 one 1 one FIRST COMMIT", file.path(repo, "a.txt"))
write("I will be deleted", file.path(repo, "b.txt"))
git_commit(all = TRUE, message = "first commit", repo = repo)
readLines(file.path(repo, "a.txt"))
readLines(file.path(repo, "b.txt"))

#' Check HEAD.  Now it exists and `git2r::head()` return value is object of S4
#' class `git_branch`. Check again with `githug:::git_HEAD()`.
head(gr)
class(head(gr))
git_HEAD(repo)

#' Modify the first file. Delete the second. Create two more files.  Commit.
write("I'm new in the second commit", file.path(repo, "c.txt"))
write("I'm also new in the second commit", file.path(repo, "d.txt"))
file.remove(file.path(repo, "b.txt"))
write("2 two 2 two 2 two SECOND COMMIT", file.path(repo, "a.txt"),
      append = TRUE)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
git_status(repo = repo)
git_commit(all = TRUE, message = "second commit", repo = repo)

#' Look at the commit history and check HEAD again. Store the commits for use
#' in resets. Use `githug::git_log()`.
(commits <- commits(gr))
git_log(repo)

#' Which files exist now in the working tree?
list.files(repo)

#' Make a change to two of the three files but only stage one. Add two more
#' files and stage one.
write("3 three 3 three 3 three", file.path(repo, "a.txt"), append = TRUE)
write("another line", file.path(repo, "c.txt"), append = TRUE)
write("new after second commit", file.path(repo, "e.txt"))
write("also new after second commit", file.path(repo, "f.txt"))
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
cat(readLines(file.path(repo, "e.txt")), sep = "\n")
cat(readLines(file.path(repo, "f.txt")), sep = "\n")
git_status(repo, ls = TRUE)
git_add("a.txt", "e.txt", repo = repo)
(status_pre_reset <- git_status(repo, ls = TRUE))

#' That up right up there ^? That is the status I (sort of) expect to get
#' back to after the reset. In any case, we'll want to compare back to this.
#'
#' Call `reset()` providing the first commit as a `git_commit` object as the
#' first argument. HEAD will now point to this commit.
reset(commits[[2]]) # soft is default
list.files(repo)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
cat(readLines(file.path(repo, "e.txt")), sep = "\n")
cat(readLines(file.path(repo, "f.txt")), sep = "\n")

#' The working tree has not been changed. Compare current status to that right
#' before the soft reset.
git_status(repo, ls = TRUE)
status_pre_reset
#' I used SourceTree to confirm the stuff below as I haven't figured out diff
#' inspection with `git2r`.
#'
#'   * The accumulated modifications of "a.txt" are staged: the addition of the
#'   second and third lines. That makes sense because this is the staged state
#'   of "a.txt" at the time of reset.
#'   * "b.txt" does not exist and its deletion is staged.
#'   * The creation and first line of "c.txt" is staged (these were part of the
#'   commit that disappeared). The addition of the second line of "c.txt" is an
#'   unstaged modification, as it was unstaged at the time of reset.
#'   * The creation of "d.txt" is staged. At the time of reset, it was tracked
#'   but unchanged.
#'   * The creation of "e.txt" is staged.
#'   * "f.txt" has been created but it is not tracked and unstaged.

git_HEAD(repo)
git_log(repo)
reflog(gr)
#' Yes HEAD is pointing to the requested commit, here the first commit. The
#' second commit disappears from the log. To get it back, you'd need to get it
#' from reflog. So, if this is what `git_uncommit()` comes to mean, will I put
#' something in place -- or message the SHA -- to document which commit has
#' been peeled off?

#' Clean up.
unlink(repo, recursive = TRUE)

#' Random question: what happens if you reset to a commit is not an ancestor of
#' current HEAD? Leaving this for now.
