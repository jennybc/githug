context("git commit")

test_that("git_commit works, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  write_file(c("a", "b"), dir = tpath)
  gc <- git_commit(all = TRUE, message = "first commit", repo = tpath)
  expect_identical(nrow(git_status_check(repo = tpath)), 0L)
  owd <- setwd(tpath)
  write_file(c("c", "d"))
  expect_message(git_commit(all = TRUE, message = "second commit", repo = tpath),
                 "Staged these paths:\n  \\* c\n  \\* d")
  expect_identical(nrow(git_status_check()), 0L)
  setwd(owd)
})

test_that("commit demands a commit message", {
  tpath <- init_tmp_repo()
  write_file("foo", dir = tpath)
  expect_error(git_commit(all = TRUE, repo = tpath),
               "You must provide a commit message")
})

test_that("explicit paths work in git_commit", {
  tpath <- init_tmp_repo()
  write_file(c("a", "b"), dir = tpath)
  expect_message(git_commit("a", "b", message = "commit", repo = tpath),
                 "Staged these paths:\n  \\* a\n  \\* b")
})

test_that("warning from git_commit if nothing staged", {
  tpath <- init_tmp_repo()
  write_file(c("a", "b"), dir = tpath)
  git_commit(all = TRUE, message = "commit", repo = tpath)
  expect_warning(git_commit(all = TRUE, message = "commit", repo = tpath),
                 "Nothing staged for commit")
})
