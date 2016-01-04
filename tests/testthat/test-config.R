context("config")

test_that("match content from unqualified git2r::config query", {

  git2r_cfg <- git2r::config()

  expect_identical(modifyList(git2r_cfg$global, git2r_cfg$local), git_config())

  expect_identical(git2r_cfg$local, git_config(where = "local"))
  expect_identical(git2r_cfg$local, git_config_local())

  expect_identical(git2r_cfg$global, git_config(where = "global"))
  expect_identical(git2r_cfg$global, git_config_global())

})

test_that("match content from repo-specific git2r::config query", {

  git2r_cfg <- git2r::config(repo = as_git_repository("repo01-blah"))
  expect_identical(git2r_cfg$local,
                   git_config(repo = "repo01-blah", where = "local"))
  expect_identical(git2r_cfg$local, git_config_local(repo = "repo01-blah"))

})

test_that("query returns specific bits of local config", {

  cfg <- read_git_config(file.path("repo01-blah", ".git", "config"))
  bits <- c("user.name", "user.email", "core.bare", "nope")
  exp_out <- setNames(as.list(cfg)[bits], bits)

  expect_identical(git_config(bits, repo = "repo01-blah"), exp_out)
  expect_identical(git_config(bits, repo = "repo01-blah", where = "local"),
                   exp_out)
  expect_identical(git_config_local(bits, repo = "repo01-blah"), exp_out)

})

test_that("query returns specific bits of global config", {

  cfg <- read_git_config(file.path("~", ".gitconfig"))
  bits <- c("user.name", "user.email", "core.bare", "nope")
  exp_out <- setNames(as.list(cfg)[bits], bits)

  expect_identical(git_config(bits, where = "global"), exp_out)
  expect_identical(git_config_global(bits), exp_out)

})

test_that("set forces and messages switch from 'where = de_facto' to 'local'", {

  tr <- init_tmp_repo()
  expect_message(git_config(foo = "bar", repo = tr), "setting local config")

})

test_that("set local config vars", {

  tr <- init_tmp_repo()
  o_cfg <- git_config_local(user.name = "julia", repo = tr)
  expect_identical(o_cfg, list(user.name = NULL))
  o_cfg <- git_config_local(user.name = "erica", repo = tr)
  expect_identical(o_cfg, list(user.name = "julia"))
  o_cfg <- git_config_local(githug.lol = "wut", repo = tr)
  expect_identical(o_cfg, list(githug.lol = NULL))
  expect_identical(git_config_local("githug.lol", repo = tr),
                   list(githug.lol = "wut"))

})

test_that("set global config vars", {

  cfg <- read_git_config(file.path("~", ".gitconfig"))
  existing_user <- unname(cfg["user.name"])

  ## existing_user --> julia
  o_cfg <- git_config_global(user.name = "julia")
  expect_identical(o_cfg, list(user.name = existing_user))

  ## julia --> existing_user
  o_cfg <- git_config_global(user.name = existing_user)
  expect_identical(o_cfg, list(user.name = "julia"))

})

test_that("round trips work", {

  tr <- init_tmp_repo()
  jenny <- list(user.name = "jenny",
                user.email = "jenny@example.org",
                color.branch = "always")
  julia <- list(user.name = "julia",
                user.email = "julia@example.org",
                color.branch = "never")
  cfg_0 <- git_config_local(jenny, repo = tr)
  cfg_1 <- git_config_local(julia, repo = tr)
  expect_identical(cfg_1, jenny)
  cfg_2 <- git_config_local(cfg_1, repo = tr)
  expect_identical(git_config_local(names(jenny), repo = tr), cfg_1)

})

test_that("calls from outside repo give sane results", {

  path <- tempfile("githug-test-NOT-A-GIT-REPO-")
  dir.create(path)

  owd <- setwd(path)

  ## queries work, but only return global config
  expect_identical(git_config(), git_config_global())
  expect_identical(git_config(), git_config(where = "global"))
  expect_identical(git_config_local(), list())
  expect_identical(git_config(where = "local"), list())

  ## local set fails
  expect_error(git_config(color.branch = "never"))

  ## global set works
  expect_is(ocfg <- git_config_global(color.branch = "never"), "list")

  git_config_global(ocfg)
  setwd(owd)
})
