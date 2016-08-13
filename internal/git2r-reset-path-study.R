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

#' ## Verifying what happens with `git2r::reset(object, path)`, where `object`
#' is a `git_repository`.
repo <- file.path("~", "tmp", "reset")

#' Clean up any previous work.
if (dir.exists(repo)) unlink(repo, recursive = TRUE)

#' Set up a repo.
repo <- git_init(repo)
gr <- as.git_repository(repo)

#' Create 2 files and commit them.
write("1 one 1 one 1 one FIRST COMMIT", file.path(repo, "a.txt"))
write("I will be deleted", file.path(repo, "b.txt"))
git_commit(all = TRUE, message = "first commit", repo = repo)
readLines(file.path(repo, "a.txt"))
readLines(file.path(repo, "b.txt"))

#' Modify the first file. Delete the second. Create another file.
write("I'm new in the second commit", file.path(repo, "c.txt"))
file.remove(file.path(repo, "b.txt"))
write("2 two 2 two 2 two SECOND COMMIT", file.path(repo, "a.txt"),
      append = TRUE)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
(status_unstaged <- git_status(repo = repo))

#' Stage all of that.
git_stage(all = TRUE, repo = repo)
(status_staged <- git_status(repo = repo))

#' Unstage those paths.
reset(gr, path = status_staged$path)
(status_reset <- git_status(repo = repo))

#' Is it same as before?
identical(status_unstaged, status_reset)

#' Clean up.
unlink(repo, recursive = TRUE)
