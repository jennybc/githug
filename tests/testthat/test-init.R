context("init")

test_that("init works in existing dir that is not a git repo", {

  tpath <- tempfile(pattern = "github-test-")
  dir.create(tpath)
  expect_true(dir.exists(tpath))
  expect_false(git2r::in_repository(tpath))
  tpath <- git_init(tpath)
  expect_true(git2r::in_repository(as.character(tpath)))

})

test_that("init works in dir that does not exist yet", {

  tpath <- tempfile(pattern = "github-test-")
  expect_false(dir.exists(tpath))
  expect_message(tpath <- git_init(tpath), "Creating directory")
  expect_true(dir.exists(tpath))
  expect_true(git2r::in_repository(as.character(tpath)))

})

test_that("init works in existing dir that is already a git repo", {

  tpath <- tempfile(pattern = "github-test-")
  tpath <- git_init(tpath)
  expect_message(tpath <- git_init(tpath),
                 "appears to be an existing git repo")
  expect_true(git2r::in_repository(as.character(tpath)))

})

test_that("init does not create a repo within a repo", {

  tpath <- tempfile(pattern = "github-test-")
  tpath <- git_init(tpath)
  expect_true(git2r::in_repository(as.character(tpath)))

  tpath_at_depth <- file.path(tpath, "dir1", "dir2")
  init_res <- git_init(tpath_at_depth)
  expect_identical(tpath, init_res)

})



