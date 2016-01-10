context("git HEAD")

test_that("we retrieve info on HEAD", {

  tpath <- init_tmp_repo()
  writeLines('a', file.path(tpath, 'a'))
  git_COMMIT('a commit', repo = tpath)
  ghead <- git_HEAD(repo = tpath)
  expect_is(ghead, "git_HEAD")
  expect_identical(ghead[c("branch_name", "branch_type")],
                   list(branch_name = "master", branch_type = "local"))
  expect_equivalent(lapply(ghead, class),
                    list(branch_name = "character", branch_type = "character",
                         head_sha = "character", head_commit = "git_commit",
                         repo = "git_repository", git_branch = "git_branch"))

})
