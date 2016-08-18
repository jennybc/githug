context("git init")

test_that("init works in dir that does not exist yet", {
  tpath <- tmp_repo_path()
  expect_false(dir.exists(tpath))
  expect_message(tpath <- git_init(tpath), "Creating directory")
  expect_true(dir.exists(tpath))
  expect_true(is_a_repo(tpath))
})

test_that("init works in existing dir that is not a git repo", {
  tpath <- tmp_repo_path()
  dir.create(tpath)
  expect_message(tpath <- git_init(tpath), "Initialising git repository")
  expect_true(is_a_repo(tpath))
})

test_that("init works in existing dir that is already a git repo", {
  tpath <- init_tmp_repo()
  expect_message(tpath <- git_init(tpath), "is already a Git repo")
})

test_that("init refuses to create a repo within a repo", {
  tpath <- init_tmp_repo()
  tpath_at_depth <- normalize_path(file.path(tpath, "dir1", "dir2"))
  expect_error(git_init(tpath_at_depth), "is or will be nested")
})

test_that("init fails informatively on path to an existing file (not dir)", {
  tpath <- tmp_repo_path()
  dir.create(tpath)
  write_file("whatever", dir = tpath)
  expect_error(git_init(file.path(tpath, "whatever")),
               "File already exists")
})
