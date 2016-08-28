context("git branch")

test_that("current branch and list when no commits or branches", {
  tpath <- init_tmp_repo()
  expect_message(gb <- git_branch(repo = tpath), "Not on a branch")
  expect_null(gb)
  expect_message(gbl <- git_branch_list(repo = tpath), "No branches to list")
  expect_null(gbl)
})

test_that("detached HEAD", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  c01 <- git_commit("a", message = "a", repo = tpath)
  write_file("b", dir = tpath)
  git_commit("b", message = "b", repo = tpath)
  ## come back when there's a better way to check out based on SHA
  ghist <- git_history(repo = tpath)
  gc01 <- ghist$commit[[which(ghist$sha == c01)]]
  git2r::checkout(gc01)
  expect_message(gb <- git_branch_current(repo = tpath), "Detached HEAD!")
  expect_identical(gb, NA_character_)
  gbl <- git_branch_list(repo = tpath)
  expect_false(any(gbl$HEAD))
})

test_that("current branch and list reporting when 1 branch exists", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_identical(git_branch(repo = tpath), "master")
  gbl <- git_branch_list(repo = tpath)
  gbl_ref <- tibble::tibble(
    HEAD = TRUE,
    full_name = "master",
    type = "local",
    branch = "master",
    remote = NA_character_
  )
  vars <- c("HEAD", "full_name", "type", "branch", "remote")
  expect_identical(gbl[vars], gbl_ref)
  expect_identical(gbl, git_branch(where = "local", repo = tpath))
  expect_identical(gbl, git_branch(where = "all", repo = tpath))
})

test_that("branch listing when 2 branches exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_branch_create("second", repo = tpath)
  gbl <- git_branch_list(repo = tpath)
  gbl_ref <- tibble::frame_data(
    ~HEAD, ~full_name, ~type, ~branch, ~remote,
    TRUE, "master", "local", "master", NA_character_,
    FALSE, "second", "local", "second", NA_character_
  )
  vars <- c("HEAD", "full_name", "type", "branch", "remote")
  expect_identical(gbl[vars], gbl_ref)
  expect_identical(gbl, git_branch(where = "local", repo = tpath))
  expect_identical(gbl, git_branch(where = "all", repo = tpath))
})
