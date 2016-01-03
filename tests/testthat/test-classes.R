context("rpath-class")

test_that("rpath doesn't accept garbage input", {
  expect_error(rpath(letters[1:2]))
  expect_error(rpath(1:2))
})

test_that("rpath returns path to enclosing git repo", {

  tpath <- tempfile(pattern = "githug-test-")

  ## path does not exist
  expect_null(rpath(tpath))
  expect_false(is_in_repo(tpath))
  expect_false(is_a_repo(tpath))

  ## path exists but there is no enclosing git repo
  dir.create(tpath)
  res <- rpath(tpath)
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
  res <- rpath(nested_path, ceiling = 0)
  expect_null(res)
  res <- rpath(nested_path, ceiling = 1)
  expect_null(res)
  expect_true( is_in_repo(nested_path))
  expect_false(is_in_repo(nested_path, ceiling = 0))
  expect_false(is_in_repo(nested_path, ceiling = 1))
  expect_false( is_a_repo(nested_path))

 })

test_that("as.rpath works on a git_repository", {

  tpath <- tempfile(pattern = "githug-test-")
  tpath <- git_init(tpath)
  expect_identical(tpath, as.rpath(git2r::repository(tpath, discover = TRUE)))

})
