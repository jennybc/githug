context("git-revision")

test_that("error if rev does not exist", {
  tpath <- init_tmp_repo()
  expect_error(git_revision(repo = tpath), "Can't find the revision")
  expect_error(git_revision(rev = "nope", repo = tpath), "Can't find the revision")
})

test_that("existence test works", {
  tpath <- init_tmp_repo()
  expect_false(git_revision_exists(rev = "nope", repo = tpath))
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_true(git_revision_exists(rev = "HEAD", repo = tpath))
})
