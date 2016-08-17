context("git branch create")

test_that("branch can be created from SHA", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  gc1 <- git_commit("a", message = "a", repo = tpath)
  write_file("b", dir = tpath)
  git_commit("b", message = "b", repo = tpath)
  gl <- git_log(repo = tpath)
  gb <- git_branch_create("new_branch", repo = tpath, sha = gl$sha[2])
  expect_identical(gc1, gb)
  expect_true("new_branch" %in% git_branch_list(repo = tpath)$branch)
})

test_that("can't create branch if name already taken", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_branch_create("master", repo = tpath),
               "name already exists")
})
