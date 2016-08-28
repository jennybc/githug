context("as.git_commit")

test_that("as.git_commit works", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  sha <- git_commit("a", message = "a", repo = tpath)
  expect_identical(sha, sha_with_hint(as.git_commit(repo = tpath)))
  expect_identical(sha, sha_with_hint(as.git_commit("HEAD", repo = tpath)))
  expect_identical(sha, sha_with_hint(as.git_commit("master", repo = tpath)))
})
