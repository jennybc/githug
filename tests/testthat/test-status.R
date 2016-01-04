context("status")

test_that("status works, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  expect_output(git_status(repo = tpath), "working directory clean")
  expect_equivalent(git_status(repo = tpath),
                    list(staged = list(), unstaged = list(),
                         untracked = list()))
  lapply(letters[1:3], function(x) writeLines(x, file.path(tpath, x)))
  expect_equivalent(git_status(repo = tpath),
                    list(staged = list(), unstaged = list(),
                         untracked = list(untracked = "a", untracked = "b",
                                          untracked = "c")))
  setwd(tpath)
  ga <- git_add(c("a", "b"))
  expect_equivalent(git_status(),
                    list(staged = list(new = "a", new = "b"),
                         unstaged = list(),
                         untracked = list(untracked = "c")))
  git_COMMIT("a commit")

  lapply(letters[4:5], function(x) writeLines(x, file.path(tpath, x)))
  file.remove("a")
  write("b", "b", append = TRUE)
  git_add("e")
  expect_equivalent(git_status(),
                    list(staged = list(new = "e"),
                         unstaged = list(deleted = "a", modified = "b"),
                         untracked = list(untracked = "d")))
})

