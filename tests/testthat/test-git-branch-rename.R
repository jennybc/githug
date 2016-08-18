context("git branch rename")

test_that("rename when from doesn't exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_branch_rename(from = "nope", to = "yep", repo = tpath),
               "No existing local branch")
})

test_that("rename when to already exists", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_create("new_branch", repo = tpath)
  expect_error(git_branch_rename(from = "new_branch", to = "master", repo = tpath),
               "name already exists")
})

test_that("can rename", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_create("new_branch", repo = tpath)
  expect_message(git_branch_rename(from = "new_branch", to = "foo", repo = tpath),
                 "Branch renamed")
})
