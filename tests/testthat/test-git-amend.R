context("git amend")

test_that("git_amend requires explicit permission to rewrite history", {
  prohibit_interaction()
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  gco <- git_commit("a", message = "commit 1", repo = tpath)
  write_file("b", dir = tpath)
  gco <- git_commit("b", message = "commit 2", repo = tpath)
  expect_message(am <- git_amend(repo = tpath),
                 "You must explicitly authorize this")
  expect_null(am)
  expect_equivalent(gco, git_history(repo = tpath, n = 1)$sha)
  allow_interaction()
})

test_that("git_amend aborts if HEAD^ does not exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  gco <- git_commit("a", message = "commit 1", repo = tpath)
  expect_error(git_amend(ask = FALSE, repo = tpath),
               "Can't find parent")
  expect_equivalent(gco, git_history(repo = tpath, n = 1)$sha)
})

test_that("empty message is pre-empted by previous message", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "commit 1", repo = tpath)
  write_file("b", dir = tpath)
  git_commit("b", message = "commit 2", repo = tpath)
  git_amend(ask = FALSE, message = "", repo = tpath)
  expect_identical(git_history(repo = tpath)$message[1], "commit 2")
})


test_that("git_amend results in new SHA, new message, new snapshot", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "commit 1", repo = tpath)
  write_file("b", dir = tpath)
  gco_old <- git_commit("b", message = "commit 2", repo = tpath)
  write("more b", file.path(tpath, "b"), append = TRUE)
  git_stage("b", repo = tpath)
  gco_new <- git_amend(message = "commit 2, take 2", ask = FALSE, repo = tpath)
  gl <- git_history(repo = tpath)
  expect_false(identical(gco_old, gco_new))
  expect_equivalent(gco_new, gl$sha[1])
  expect_identical(gl$message[1], "commit 2, take 2")
  expect_output(expect_identical(nrow(git_status(repo = tpath)), 0L))
  expect_identical(readLines(file.path(tpath, "b")), c("b", "more b"))
})
