context("rpath and githug_list classes")

test_that("rpath doesn't accept garbage input", {
  expect_error(rpath(letters[1:2]))
  expect_error(rpath(1:2))
})

test_that("rpath returns path to enclosing git repo", {

  tpath <- tempfile("githug-test-")

  ## path does not exist
  expect_error(as.rpath(tpath), "no path exists")
  expect_null(as.rpath(tpath, raise = NULL))
  expect_false(is_in_repo(tpath))
  expect_false(is_a_repo(tpath))

  ## path exists but there is no enclosing git repo
  dir.create(tpath)
  res <- rpath(tpath, raise = NULL)
  expect_null(res)
  expect_false(is_in_repo(tpath))
  expect_false(is_a_repo(tpath))
  unlink(tpath)

  ## path IS a git repo
  tpath <- git_init(tpath)
  res <- rpath(tpath)
  expect_identical(tpath, res)
  expect_true(is_in_repo(tpath))
  expect_true(is_a_repo(tpath))

  ## path is nested within a git repo
  nested_path <- file.path(tpath, "one", "two")
  dir.create(nested_path, recursive = TRUE)
  res <- rpath(nested_path)
  expect_identical(tpath, res)
  expect_error(rpath(nested_path, ceiling = 0), "no git repo exists")
  res <- rpath(nested_path, ceiling = 0, raise = NULL)
  expect_null(res)
  expect_error(rpath(nested_path, ceiling = 1), "no git repo exists")
  res <- rpath(nested_path, ceiling = 1, raise = NULL)
  expect_null(res)
  expect_true( is_in_repo(nested_path))
  expect_false(is_in_repo(nested_path, ceiling = 0))
  expect_false(is_in_repo(nested_path, ceiling = 1))
  expect_false( is_a_repo(nested_path))

 })

test_that("as.rpath works on a git_repository", {

  tpath <- init_tmp_repo()
  expect_identical(tpath, as.rpath(git2r::repository(tpath, discover = TRUE)))

})

test_that("git_config returns objects of class githug_list", {
  ## querying
  cfg <-  git_config()
  expect_is(cfg, "githug_list")
  ## setting
  tr <- init_tmp_repo()
  cfg_0 <- git_config_local(list(`blah.foo` = "a"), repo = tr)
  expect_is(cfg_0, "githug_list")
  cfg_1 <- git_config_local(list(`blah.foo` = "b"), repo = tr)
  expect_is(cfg_1, "githug_list")
})

test_that("objects of class githug_list retain class after `[`", {
  cfg <-  git_config()
  expect_is(cfg[1:2], "githug_list")
  expect_is(cfg[1], "githug_list")
})
