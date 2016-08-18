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

#' ## Checking that `githug::uncommit()` + `git_unstage(all = TRUE)` leaves
#' status same as `git2r::reset(<HEAD^>, "mixed")`.
repo <- file.path("~", "tmp", "reset")

#' Clean up any previous work.
if (dir.exists(repo)) unlink(repo, recursive = TRUE)

#' Set up a repo.
repo <- git_init(repo)
gr <- as.git_repository(repo)

#' Create 2 files and commit them.
write("a line 1", file.path(repo, "a.txt"))
write("I will be deleted", file.path(repo, "b.txt"))
git_commit(all = TRUE, message = "first commit", repo = repo)
readLines(file.path(repo, "a.txt"))
readLines(file.path(repo, "b.txt"))

#' Modify the first file. Delete the second. Create another file. Commit.
write("I'm new in the second commit", file.path(repo, "c.txt"))
file.remove(file.path(repo, "b.txt"))
write("a line 2", file.path(repo, "a.txt"), append = TRUE)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
git_commit(all = TRUE, message = "second commit", repo = repo)
git_log(repo)

#' Uncommit and unstage.
git_uncommit(repo = repo)
git_unstage(all = TRUE, repo = repo)
(status_unx2 <- git_status(repo = repo))

#' Restage and commit.
git_commit(all = TRUE, message = "second commit, take two", repo = repo)
git_log(repo)

#' Mixed reset.
reset(git_log(repo)$commit[[2]], reset_type = "mixed")
(status_reset <- git_status(repo = repo))

#' Is it same as before?
identical(status_unx2, status_reset)

#' Clean up.
unlink(repo, recursive = TRUE)
