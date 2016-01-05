context("commit log")

test_that("git_log works, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  expect_message(gl <- git_log(repo = tpath), "no commits yet")
  expect_null(gl)

  writeLines("a", file.path(tpath, "a"))
  git_COMMIT("a", repo = tpath)
  expect_message(gl <- git_log(repo = tpath), NA)
  expect_identical(dim(gl), c(1L, 6L))
  expect_identical(names(gl),
                   c("message", "when", "author", "sha", "email", "summary"))

  setwd(tpath)
  writeLines("b", file.path(tpath, "b"))
  git_COMMIT("b", repo = tpath)
  expect_message(gl <- git_log(), NA)
  expect_identical(dim(gl), c(2L, 6L))
  expect_identical(gl$message, c("b", "a"))

})

test_that("git_log returns sthg of class git_log, tbl_df", {

  tpath <- init_tmp_repo()
  writeLines("a", file.path(tpath, "a"))
  git_COMMIT("a", repo = tpath)
  gl <- git_log(repo = tpath)
  expect_is(gl, c("git_log", "tbl_df"))

})
