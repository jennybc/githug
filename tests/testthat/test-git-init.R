context("git init")

test_that("init works in existing dir that is not a git repo", {

  tpath <- tempfile("githug-test-")
  dir.create(tpath)
  expect_true(dir.exists(tpath))
  expect_false(git2r::in_repository(tpath))
  tpath <- git_init(tpath)
  expect_true(git2r::in_repository(tpath))

})

test_that("init works in dir that does not exist yet", {

  tpath <- tempfile("githug-test-")
  expect_false(dir.exists(tpath))
  expect_message(tpath <- git_init(tpath), "Creating directory")
  expect_true(dir.exists(tpath))
  expect_true(git2r::in_repository(tpath))

})

test_that("init works in existing dir that is already a git repo", {

  tpath <- init_tmp_repo()
  expect_true(git2r::in_repository(tpath))
  expect_message(tpath <- git_init(tpath), "appears to already be a Git repo")

})

test_that("init creates a repo within a repo iff 'force = TRUE'", {

  tpath <- init_tmp_repo()
  expect_true(git2r::in_repository(tpath))

  tpath_at_depth <-
    normalizePath(file.path(tpath, "dir1", "dir2"), mustWork = FALSE)

  expect_message(init_res <- git_init(tpath_at_depth),
                 "use 'git_init\\(path, force = TRUE\\)'")
  expect_null(init_res)

  expect_message(init_res <- git_init(tpath_at_depth, force = TRUE),
                 "Doing `git init`")
  expect_identical(init_res, tpath_at_depth)

})
