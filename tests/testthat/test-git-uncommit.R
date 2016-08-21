context("git uncommit")

test_that("git_uncommit requires explicit permission to rewrite history", {
  prohibit_interaction()
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  gco <- git_commit("a", message = "commit 1", repo = tpath)
  write_file("b", dir = tpath)
  gco <- git_commit("b", message = "commit 2", repo = tpath)
  expect_message(un <- git_uncommit(repo = tpath),
                 "You must explicitly authorize this")
  expect_null(un)
  expect_equivalent(gco, git_history(repo = tpath, n = 1)$sha)
  allow_interaction()
})

test_that("git_uncommit moves HEAD back to parent and leaves things staged", {

  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "commit 1", repo = tpath)
  write_file("b", dir = tpath)
  git_commit("b", message = "commit 2", repo = tpath)
  gl <- git_history(repo = tpath)
  expect_identical(nrow(gl), 2L)
  gco <- git_uncommit(ask = FALSE, repo = tpath)
  expect_identical(nrow(git_history(repo = tpath)), 1L)
  expect_equivalent(gl$sha[[2]], gco)
  expect_status(git_status_check(ls = TRUE, repo = tpath),
                tibble::frame_data(
                  ~status,   ~path, ~change,
                  "staged",  "b",   "new",
                  "tracked", "a",   "none"
                ))
})

test_that("git_uncommit aborts if HEAD^ does not exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "commit 1", repo = tpath)
  expect_error(git_uncommit(ask = FALSE, repo = tpath),
               "Can't find the parent")
})
