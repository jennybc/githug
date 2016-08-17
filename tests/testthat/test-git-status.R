context("git status")

empty_status <-  tibble::tibble(status = character(),
                                path = character(),
                                change = character(),
                                i = integer())

test_that("git_status() messages current branch", {
  tpath <- init_tmp_repo()
  write_file("a", dir = tpath)
  git_commit("a", message = "init", repo = tpath)
  expect_message(git_status(repo = tpath), "On branch:\n  \\* master")
})

test_that("status messages and returns NULL if not in git repo", {
  tpath <- tmp_repo_path()
  dir.create(tpath)
  expect_true(dir.exists(tpath))
  expect_false(is_in_repo(tpath))
  expect_error(git_status(repo = tpath), "no git repo exists here")
})

test_that("status in empty repo", {
  tpath <- init_tmp_repo()
  expect_identical(git_status_check(repo = tpath), empty_status)
})

test_that("status reports new files", {
  tpath <- init_tmp_repo()
  write_file(c("staged", "untracked", "tracked", "ignored"), dir = tpath)
  write("ignored", file.path(tpath, ".gitignore"))
  git_commit(c(".gitignore", "tracked"), message = "init", repo = tpath)
  git_add("staged", repo = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,     ~path,
                  "staged",    "staged",
                  "untracked", "untracked"
                ))
  expect_status(git_status_check(repo = tpath, ls = TRUE),
                tibble::frame_data(
                  ~status,     ~path,
                  "staged",    "staged",
                  "untracked", "untracked",
                  "ignored",   "ignored",
                  "tracked",   "tracked"
                ))
})

test_that("status reports deleted files", {
  tpath <- init_tmp_repo()
  files <- c("staged", "unstaged")
  write_file(files, dir = tpath)
  git_commit(files, message = "init", repo = tpath)
  file.remove(file.path(tpath, files))
  git_add("staged", repo = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,    ~path,      ~change,
                  "staged",   "staged",   "deleted",
                  "unstaged", "unstaged", "deleted"
                ))
})

test_that("status reports modified files", {
  tpath <- init_tmp_repo()
  files <- c("staged", "unstaged", "both")
  write_file(files, dir = tpath)
  git_commit(files, message = "init", repo = tpath)
  lapply(files,
         function(x) write("another line", file.path(tpath, x), append = TRUE))
  git_add(c("staged", "both"), repo = tpath)
  write("yet another line", file.path(tpath, "both"), append = TRUE)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status,    ~path,      ~change,
                  "staged",   "both",     "modified",
                  "staged",   "staged",   "modified",
                  "unstaged", "both",     "modified",
                  "unstaged", "unstaged", "modified"
               ))
})

test_that("status reports renamed files", {
  tpath <- init_tmp_repo()
  write_file("from", dir = tpath)
  git_commit("from", message = "init", repo = tpath)
  file.rename(file.path(tpath, "from"), file.path(tpath, "to"))
  git_add(c("from", "to"), repo = tpath)
  expect_status(git_status_check(repo = tpath),
                tibble::frame_data(
                  ~status, ~ path,  ~change,        ~i,
                  "staged", "from", "renamed_from", 1L,
                  "staged", "to",   "renamed_to",   1L
                ))
})

test_that("status reports tracked unchanged + ignored files when all = TRUE", {
  tpath <- init_tmp_repo()
  write_file(c("tracked", "ignored"), dir = tpath)
  write("ignored", file.path(tpath, ".gitignore"))
  git_commit(c(".gitignore", "tracked"), message = "init", repo = tpath)
  expect_status(git_status_check(repo = tpath, ls = TRUE),
                tibble::frame_data(
                  ~status,   ~path,     ~change,
                  "ignored", "ignored", "new",
                  "tracked", "tracked", "none"
                ))
})

test_that("status when git2r::status returns nothing but all = TRUE", {
  tpath <- init_tmp_repo()
  write_file("a_file", dir = tpath)
  git_commit("a_file", message = "init", repo = tpath)
  expect_status(git_status_check(repo = tpath, ls = TRUE),
                tibble::frame_data(
                  ~status,   ~path,    ~change,
                  "tracked", "a_file", "none"
                ))
})
