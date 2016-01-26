context("githug init")

test_that("githug init works", {
  skip_if_no_internet()
  tpath <- githug_init(path = tempfile("githug-init-test-"))
  expect_true(dir.exists(tpath))
  expect_true(is_a_repo(tpath))
  expect_true(wd_is_clean(tpath))
  #expect_true(is_a_rsp(tpath))
  gcfg_local <- git_config_local(repo = tpath)
  expect_identical(gcfg_local$githug.remotename, "origin")
  ## use an explicit check for tracking, when it exists
  expect_identical(gcfg_local$branch.master.remote, "origin")
  githug_urls <- grep("githug\\..*url", names(gcfg_local), value = TRUE)
  expect_identical(length(githug_urls), 3L)
})
