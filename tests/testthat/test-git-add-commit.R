context("git add and commit")

test_that("add and ADD work, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  lapply(letters[1:4], function(x) writeLines(x, file.path(tpath, x)))
  expect_equivalent(git_status(repo = tpath),
                    list(staged = list(), unstaged = list(),
                         untracked = list(untracked = "a", untracked = "b",
                                          untracked = "c", untracked = "d")))
  ga <- git_add(c("a", "c"), repo = tpath)
  expect_identical(tpath, ga)
  setwd(tpath)
  expect_equivalent(git_status(),
                    list(staged = list(new = "a", new = "c"),
                         unstaged = list(),
                         untracked = list(untracked = "b", untracked = "d")))
  git_ADD()
  expect_equivalent(git_status(),
                    list(staged = list(new = "a", new = "b",
                                       new = "c", new = "d"),
                         unstaged = list(),
                         untracked = list()))

})

test_that("commit and COMMIT work, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  lapply(letters[1:2], function(x) writeLines(x, file.path(tpath, x)))
  git_ADD(repo = tpath)
  expect_equivalent(git_status(repo = tpath),
                    list(staged = list(new = "a", new = "b"),
                         unstaged = list(),
                         untracked = list()))
  gc <- git_commit("first commit", repo = tpath)
  expect_identical(gc, tpath)
  expect_output(git_status(repo = tpath), "working directory clean")
  setwd(tpath)
  lapply(letters[3:4], function(x) writeLines(x, file.path(tpath, x)))
  expect_equivalent(git_status(),
                    list(staged = list(),
                         unstaged = list(),
                         untracked = list(untracked = "c", untracked = "d")))
  git_COMMIT("second commit")
  expect_output(git_status(), "working directory clean")

})

test_that("commit demands a commit message", {

  tpath <- init_tmp_repo()
  lapply(letters[1:2], function(x) writeLines(x, file.path(tpath, x)))
  git_ADD(repo = tpath)
  expect_error(git_commit(repo = tpath), "You must provide a commit message")

})

test_that("ADD and COMMIT admit it when there's nothing to be done", {

  tpath <- init_tmp_repo()
  expect_message(git_ADD(repo = tpath), "nothing to ADD")
  expect_message(git_COMMIT("but there's nothing to commit!", repo = tpath),
                 "nothing to ADD")

})
