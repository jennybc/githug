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

here <- rprojroot::find_package_root_file
library(purrr) # for %>%
devtools::load_all(here())

#' I need to see what happens when `git_switch()` gets called in a
#' noninteractive session, in order to write the tests.
#'
#' No commits, no branches.
tpath <- init_tmp_repo()
git_switch(repo = tpath)

#' Yes a commit, yes a branch exists, but not the one I'm asking for.
write_file("a", dir = tpath)
git_commit("a", message = "a", repo = tpath)
git_switch("b", repo = tpath)
