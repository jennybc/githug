context("utils")

test_that("dir_exists, w/o and w/ trailing slash", {
  tpath <- tmp_repo_path()
  tpath <- gsub("/$", "", tpath)
  tpath2 <- paste0(tpath, "/")
  expect_false(dir_exists(tpath))
  expect_false(dir_exists(tpath2))
  dir.create(tpath)
  expect_true(dir_exists(tpath))
  expect_true(dir_exists(tpath2))
})
