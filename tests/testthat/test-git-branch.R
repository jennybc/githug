context("git branch")

test_that("git_branch_list errors when not in git repo", {

  tpath <- tempfile("githug-test-")
  expect_error(git_branch_list(repo = tpath), "no path exists")
  dir.create(tpath)
  expect_error(git_branch_list(repo = tpath), "no git repo exists")

})

test_that("new repo lists no branch, then local master branch", {

  tpath <- init_tmp_repo()

  ## no commits yet
  expect_message(gb <- git_branch_list(repo = tpath), NA)
  expect_is(gb, "tbl_df")
  expect_identical(dim(gb), c(0L, 3L))

  ## yes commits
  writeLines('a', file.path(tpath, 'a'))
  git_COMMIT('a commit', repo = tpath)
  expect_message(gbl <- git_branch_list(repo = tpath), NA)
  expect_is(gbl, "tbl_df")
  expect_equal(gbl[c("name", "type")],
               dplyr::data_frame(name = "master", type = "local"))

})

test_that("we can create then checkout a branch", {

  tpath <- init_tmp_repo()

  ## no commits yet --> ergo nothing for branch to point to
  expect_error(git_branch_create("alpha", repo = tpath))

  writeLines('a', file.path(tpath, 'a'))
  git_COMMIT('a commit', repo = tpath)
  expect_identical(git_branch_create("alpha", repo = tpath), "alpha")
  gbl <- git_branch_list(repo = tpath)
  expect_is(gbl, "tbl_df")
  expect_equal(gbl[c("name", "type")],
               dplyr::data_frame(name = c("alpha", "master"),
                                          type = c("local", "local")))

})



