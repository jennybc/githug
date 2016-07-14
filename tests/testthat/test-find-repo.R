context("detect and find repo")

test_that("find_repo_path detects invalid input", {
  expect_error(find_repo_path(letters[1:2]), "length\\(x\\) == 1L is not TRUE")
  expect_error(find_repo_path(1), "inherits\\(x, \"character\"\\) is not TRUE")
})

test_that("nonexistent directory", {
  tpath <- tmp_repo_path()
  expect_error(find_repo_path(tpath), "path does not exist")
  expect_false(is_in_repo(tpath))
  expect_false(is_a_repo(tpath))
})

test_that("dir exists but is not a git repo", {
  tpath <- tmp_repo_path()
  dir.create(tpath)
  expect_error(find_repo_path(tpath), "no git repo exists here")
  expect_false(is_in_repo(tpath))
  expect_false(is_a_repo(tpath))
})

test_that("dir is a git repo", {
  tpath <- init_tmp_repo()
  res <- find_repo_path(tpath)
  expect_identical(tpath, res)
  expect_true(is_in_repo(tpath))
  expect_true(is_a_repo(tpath))
})

test_that("dir is descendant of a git repo", {
  tpath <- init_tmp_repo()
  nested_path <- file.path(tpath, "one", "two")
  dir.create(nested_path, recursive = TRUE)
  res <- find_repo_path(nested_path)
  expect_identical(tpath, res)
  expect_true(is_in_repo(nested_path))
  expect_false(is_a_repo(nested_path))

  ## does ceiling get honored?

  ## don't walk up at all
  expect_error(find_repo_path(nested_path, ceiling = 0), "no git repo exists")
  expect_false(is_in_repo(nested_path, ceiling = 0))
  expect_false(is_in_repo(nested_path, ceiling = 1))

  ## walk one level up
  expect_error(find_repo_path(nested_path, ceiling = 1), "no git repo exists")
  expect_false(is_in_repo(nested_path, ceiling = 1))

})

test_that("we default to the obvious repo", {
  tpath <- init_tmp_repo()
  gr <- as.git_repository(tpath)

  owd <- setwd(tpath)

  expect_identical(tpath, find_repo_path())
  expect_identical(gr, as.git_repository())

  nested_path <- file.path(tpath, "one", "two")
  dir.create(nested_path, recursive = TRUE)
  setwd(nested_path)
  expect_identical(tpath, find_repo_path())
  expect_identical(gr, as.git_repository())

  setwd(owd)
})
