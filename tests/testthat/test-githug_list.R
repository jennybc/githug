context("githug_list class")

test_that("objects of class githug_list retain class after `[`", {
  cfg <-  git_config()
  expect_is(cfg[1:2], "githug_list")
  expect_is(cfg[1], "githug_list")
})

test_that("NULLs are printed in githug_list object", {
  tr <- init_tmp_repo()
  cfg <- git_config("blah.foo", repo = tr)
  expect_output(print(cfg), "blah.foo = NULL")
})
