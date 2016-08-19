context("git unstage")

test_that("git_unstage all = TRUE", {

  tpath <- init_tmp_repo()
  write_file(c("a", "b"), dir = tpath)
  git_commit(all = TRUE, message = "first commit", repo = tpath)
  write("more a", file.path(tpath, "a"), append = TRUE)
  file.remove(file.path(tpath, "b"))
  write_file("c", dir = tpath)
  status_before <- git_status_check(repo = tpath)
  git_add(all = TRUE, repo = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,  ~path, ~change,
                  "staged", "c",   "new",
                  "staged", "a",   "modified",
                  "staged", "b",   "deleted"
                ))
  git_unstage(all = TRUE, repo = tpath)
  expect_status(git_status_check(repo = tpath), status_before)
})

test_that("git_unstage() admits when it can't do anything", {
  prohibit_interaction()
  tpath <- init_tmp_repo()
  expect_message(git_unstage(repo = tpath), "Nothing to unstage")
  write_file("a", dir = tpath)
  expect_message(git_unstage(repo = tpath), "Nothing to unstage")
  git_add("a", repo = tpath)
  expect_message(git_unstage(repo = tpath), "Either provide")
  git_commit(all = TRUE, message = "message", repo = tpath)
  expect_message(git_unstage(repo = tpath), "Nothing to unstage")
  allow_interaction()
})
