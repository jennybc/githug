context("git branch")

test_that("git_branch_list errors when not in git repo", {

  tpath <- tempfile("githug-test-")
  expect_error(git_branch_list(repo = tpath), "no path exists")
  dir.create(tpath)
  expect_error(git_branch_list(repo = tpath), "no git repo exists")

})

test_that("new repo lists no branch .. <commit> .. then local master branch", {

  tpath <- init_tmp_repo()

  ## no commits yet
  expect_message(gb <- git_branch_list(repo = tpath), "No branches to list.")
  expect_null(gb)

  ## yes commits
  writeLines('a', file.path(tpath, 'a'))
  git_COMMIT('a commit', repo = tpath)
  expect_message(gbl <- git_branch_list(repo = tpath), NA)
  expect_is(gbl, "tbl_df")
  expect_equal(gbl[c("name", "type")],
               dplyr::data_frame(name = "master", type = "local"))

})

test_that("we can create then checkout a branch", {

  tpath <- init_tmp_repo()

  ## no commits yet --> ergo nothing for branch to point to
  expect_error(git_branch_create("alpha", repo = tpath))

  writeLines('a', file.path(tpath, 'a'))
  git_COMMIT('a commit', repo = tpath)

  expect_identical(git_branch_create("alpha", repo = tpath), "alpha")
  gbl <- git_branch_list(repo = tpath)
  expect_is(gbl, "tbl_df")
  expect_equal(gbl[c("name", "type")],
               dplyr::data_frame(name = c("alpha", "master"),
                                 type = c("local", "local")))

  expect_message(gco <- git_checkout("alpha", repo = tpath),
                 "Switched to branch 'alpha'")
  expect_identical(gco, "alpha")
  ghead <- git_HEAD(repo = tpath)
  expect_identical(ghead$branch_name, "alpha")

})

test_that("we can pass args through to git2r::branch_create", {

  tpath <- init_tmp_repo()
  writeLines("Hello world!", file.path(tpath, "world.txt"))
  git_COMMIT("01_world", repo = tpath)
  writeLines("Hello universe!", file.path(tpath, "universe.txt"))
  git_COMMIT("02_universe", repo = tpath)

  ## point new branch at an earlier commit not HEAD
  ## can I pass 'commit' through?
  gl <- git_log(repo = tpath)
  world_commit <- grep("01_world", gl$message)
  expect_message(b <- git_branch_create("world_branch", repo = tpath,
                                        commit  = gl$commit[[world_commit]]),
                 "Creating branch world_branch")
  git_checkout(b, repo = tpath)
  hc <- git_HEAD(repo = tpath)$head_commit
  expect_match(hc@message, "01_world")

  ## back to master then force re-create world_branch pointing at HEAD
  ## can I pass 'force' through?
  git_checkout(repo = tpath)
  expect_message(
    b <- git_branch_create("world_branch", repo = tpath, force = TRUE),
    "Creating branch world_branch"
  )
  git_checkout(b, repo = tpath)
  hc <- git_HEAD(repo = tpath)$head_commit
  expect_match(hc@message, "02_universe")

})

test_that("you can't checkout a branch that doesn't exist", {

  tpath <- init_tmp_repo()
  expect_error(git_checkout("nope", repo = tpath), "does not match")

})

test_that("you can CREATE AND CHECKOUT ALL AT ONCE!", {

  tpath <- init_tmp_repo()
  writeLines("Hello world!", file.path(tpath, "world.txt"))
  git_COMMIT("01_world", repo = tpath)
  gco <- git_CHECKOUT("BOOM", repo = tpath)
  gbl <- git_branch_list(repo = tpath)

  ## did we create it?
  expect_match(gbl$name, "BOOM", all = FALSE)

  ## did we check it out?
  expect_identical(git_HEAD(repo = tpath)$branch_name, "BOOM")

})

test_that("you can delete a branch", {

  tpath <- init_tmp_repo()
  writeLines("Hello world!", file.path(tpath, "world.txt"))
  git_COMMIT("01_world", repo = tpath)
  git_branch_create("branch", repo = tpath)
  git_branch_delete("branch", repo = tpath)

})

test_that("you can't delete a branch that doesn't exist", {

  tpath <- init_tmp_repo()
  expect_error(git_branch_delete("nope"), "does not match")

})

test_that("you can't delete the branch you are on", {

  tpath <- init_tmp_repo()
  writeLines("Hello world!", file.path(tpath, "world.txt"))
  git_COMMIT("01_world", repo = tpath)

  boom <- git_CHECKOUT("BOOM", repo = tpath)
  writeLines("Hello universe!", file.path(tpath, "universe.txt"))
  git_COMMIT("02_universe", repo = tpath)

  expect_error(git_branch_delete("BOOM", repo = tpath), "current HEAD")

})
