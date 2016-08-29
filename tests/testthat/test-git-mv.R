context("git mv")

test_that("fail if from does not exist or to does exist", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  expect_error(git_mv(from = "b", to = "z", repo = tpath),
               "file_exists\\(from_path\\) is not TRUE")
  write_file("z", dir = tpath)
  expect_error(git_mv(from = "a", to = "z", repo = tpath),
               "!file_exists\\(to_path\\) is not TRUE")
})

test_that("file is renamed and staged", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "a", repo = tpath)
  git_mv(from = "a", to = "b", repo = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,  ~path,      ~change, ~i,
                  "staged",   "a", "renamed_from", 1L,
                  "staged",   "b",   "renamed_to", 1L
                ))
  expect_false(file.exists(file.path(tpath, "a")))
  expect_true(file.exists(file.path(tpath, "b")))
})
