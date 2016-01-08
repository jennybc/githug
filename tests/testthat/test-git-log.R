context("git log")

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
  writeLines("b", "b")
  git_COMMIT("b")
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

test_that("git_log warns if no git repo", {

  tpath <- tempfile("githug-test-")
  dir.create(tpath)
  expect_true(dir.exists(tpath))
  expect_warning(res <- git_log(repo = tpath), "no git repo exists")
  expect_null(res)

})

test_that("git_log printing", {

  tpath <- init_tmp_repo()
  writeLines("a", file.path(tpath, "a"))
  git_COMMIT("Goddamn it! I've never been lucky! Not one time!", repo = tpath)
  glo <- capture.output(git_log(repo = tpath))
  expect_equal_to_reference(glo, "git_log_print_output.rds")

})
