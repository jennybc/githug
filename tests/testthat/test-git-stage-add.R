context("git stage or add")

test_that("git_stage works, with repo elsewhere and in wd", {

  tpath <- init_tmp_repo()
  write_file(letters[1:4], dir = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,     ~path, ~change,
                  "untracked", "a",   "new",
                  "untracked", "b",   "new",
                  "untracked", "c",   "new",
                  "untracked", "d",   "new"
                ))
  git_stage("a", "c", repo = tpath)
  owd <- setwd(tpath)
  expect_status(git_status_check(),
                tibble::frame_data(
                  ~status,     ~path,
                  "staged",    "a",
                  "staged",    "c",
                  "untracked", "b",
                  "untracked", "d"
                ))
  git_stage(all = TRUE)
  expect_status(git_status_check(),
                tibble::frame_data(
                  ~status,  ~path,
                  "staged", "a",
                  "staged", "b",
                  "staged", "c",
                  "staged", "d"
                ))
  setwd(owd)
})

test_that("git_stage() admits when it can't do anything", {
  tpath <- init_tmp_repo()
  expect_message(git_add(repo = tpath, all = TRUE), "No changes to stage")
  write_file("whatever", dir = tpath)
  expect_message(git_add(repo = tpath), "Nothing staged")
  expect_message(git_add(repo = tpath, all = FALSE), "No changes staged")
})

test_that("git_stage() correctly messages when re-staging a file", {
  tpath <- init_tmp_repo()
  write_file("whatever", dir = tpath)
  git_add("whatever", repo = tpath)
  write("something", file.path(tpath, "whatever"), append = TRUE)
  expect_message(git_stage("whatever", repo = tpath), "Staged.*whatever")
})

test_that("git_stage() of an ignored file", {
  tpath <- init_tmp_repo()
  write_file("ignore-me", dir = tpath)
  write("ignore-me", file.path(tpath, ".gitignore"))
  git_commit(".gitignore", message = "commit", repo = tpath)
  expect_message(git_stage("ignore-me", repo = tpath), "not have been staged")
  expect_message(git_stage("ignore-me", force = TRUE, repo = tpath),
                 "Staged these paths:\n  \\* ignore-me")
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,  ~path,       ~change, ~i,
                  "staged", "ignore-me", "new",   NA_integer_
                ))
})
