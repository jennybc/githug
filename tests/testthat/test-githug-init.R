context("githug init")

test_that("githug init works", {
  skip_if_no_internet()
  tpath <- githug_init(path = tmp_repo_path("githug-init"))
  expect_true(dir.exists(tpath))
  expect_true(is_a_repo(tpath))
  expect_true(wd_is_clean(tpath))
  cat(dir(tpath, all.files = TRUE), sep = "\n")
  cat("path to templates: ",
      system.file("templates", package = "githug"), "\n")
  cat("path to template.Rproj: ",
      system.file("templates/template.Rproj", package = "githug"), "\n")
  expect_true(is_a_rsp(tpath))
  gcfg_local <- git_config_local(repo = tpath)
  expect_identical(gcfg_local$githug.remotename, "origin")
  ## use an explicit check for tracking, when it exists
  expect_identical(gcfg_local$branch.master.remote, "origin")
  githug_urls <- grep("githug\\..*url", names(gcfg_local), value = TRUE)
  expect_identical(length(githug_urls), 3L)
})
