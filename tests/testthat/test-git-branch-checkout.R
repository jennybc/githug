context("git branch checkout")

test_that("check out when no commits or branches exists", {
  tpath <- init_tmp_repo()
  expect_error(git_switch(repo = tpath), "Aborting")
  expect_error(git_branch_checkout(repo = tpath), "Aborting")
})

test_that("check out when requested branch does not exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_switch("b", repo = tpath), "Aborting")
  expect_error(git_branch_checkout("b", repo = tpath), "Aborting")
})

test_that("check out existing branch", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_create("new_branch", repo = tpath)

  git_branch_checkout("new_branch", repo = tpath)
  expect_identical(git_branch(repo = tpath), "new_branch")

  git_switch(repo = tpath)
  expect_identical(git_branch(repo = tpath), "master")

  git_switch("new_branch", repo = tpath)
  expect_identical(git_branch(repo = tpath), "new_branch")
})

test_that("create and check out works from git_branch_checkout", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_checkout("new_branch", create = TRUE, repo = tpath)
  expect_identical(git_branch(repo = tpath), "new_branch")
})

test_that("create and check out works from git_switch", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_switch("new_branch", create = TRUE, repo = tpath)
  expect_identical(git_branch(repo = tpath), "new_branch")
})

test_that("at risk files protected when 'force = FALSE' and not when 'force = TRUE'", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)

  git_branch_checkout("new_branch", create = TRUE, repo = tpath)
  write("new_branch a", file = file.path(tpath, "a"), append = TRUE)
  git_commit("a", message = "new_branch a", repo = tpath)

  git_branch_checkout(repo = tpath)
  write("master a", file = file.path(tpath, "a"), append = TRUE)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                     ~status, ~path,   ~change,
                  "unstaged",   "a", "modified"
                ))
  expect_error(git_branch_checkout("new_branch", repo = tpath),
               "conflict prevents checkout")
  expect_error(git_switch("new_branch", repo = tpath),
               "conflict prevents checkout")
  expect_message(git_branch_checkout("new_branch", repo = tpath, force = TRUE),
                 "Switched to branch")
  expect_true("new_branch a" %in% readLines(file.path(tpath, "a")))
})

