context("git branch delete")

test_that("can delete", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_create("new_branch", repo = tpath)
  expect_true("new_branch" %in% git_branch_list(repo = tpath)$branch)
  expect_message(git_branch_delete("new_branch", repo = tpath),
                 "Branch deleted")
  expect_false("new_branch" %in% git_branch_list(repo = tpath)$branch)
})

test_that("can't delete non-existent branch", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_branch_delete("nope", repo = tpath),
               "No existing local branch")
})

test_that("can't delete current branch", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_branch_delete("master", repo = tpath),
               "Cannot delete")
})
