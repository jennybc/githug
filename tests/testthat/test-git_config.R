context("git config")

test_that("match content from unqualified git2r::config query", {
  git2r_cfg <- git2r::config()
  ## de_facto
  expect_equivalent(modifyList(git2r_cfg$global, git2r_cfg$local), git_config())
  ## local only
  expect_equivalent(git2r_cfg$local, git_config(where = "local"))
  expect_equivalent(git2r_cfg$local, git_config_local())
  ## global only
  expect_equivalent(git2r_cfg$global, git_config(where = "global"))
  expect_equivalent(git2r_cfg$global, git_config_global())
})

test_that("match content from repo-specific git2r::config query", {
  tpath <- init_tmp_repo()
  git_config_local(user.name = "louise", user.email = "louise@example.org",
                   repo = tpath)
  git2r_cfg <- git2r::config(repo = as.git_repository(tpath))
  expect_equivalent(git2r_cfg$local, git_config(where = "local", repo = tpath))
  expect_equivalent(git2r_cfg$local, git_config_local(repo = tpath))
})

test_that("set forces and messages switch from 'where = de_facto' to 'local'", {
  tr <- init_tmp_repo()
  expect_message(git_config(`foo.foo` = "bar", repo = tr),
                 "setting where = \"local\"")
})

test_that("set local config vars", {
  tr <- init_tmp_repo()
  ## in an existing section
  o_cfg <- git_config_local(user.name = "julia", repo = tr)
  expect_equivalent(o_cfg, list(user.name = NULL))
  o_cfg <- git_config_local(user.name = "erica", repo = tr)
  expect_equivalent(o_cfg, list(user.name = "julia"))
  ## in a custom section
  o_cfg <- git_config_local(githug.lol = "wut", repo = tr)
  expect_equivalent(o_cfg, list(githug.lol = NULL))
  expect_equivalent(git_config_local("githug.lol", repo = tr),
                    list(githug.lol = "wut"))
})

test_that("set global config vars", {
  cfg <- read_git_config(file.path("~", ".gitconfig"))
  existing_user <- cfg["user.name"]

  ## existing_user --> julia
  new_user <- list(user.name = "julia")
  o_cfg <- git_config_global(new_user)
  expect_equivalent(o_cfg, existing_user)

  ## julia --> existing_user
  o_cfg <- git_config_global(existing_user)
  expect_equivalent(o_cfg, new_user)
})

test_that("list specific bits of local config", {
  tpath <- init_tmp_repo()
  git_config_local(user.name = "louise", user.email = "louise@example.org",
                   repo = tpath)
  cfg <- read_git_config(file.path(tpath, ".git", "config"))
  bits <- c("user.name", "user.email", "core.bare", "nope")
  exp_out <- stats::setNames(cfg[bits], bits)
  expect_equivalent(git_config(bits, repo = tpath), exp_out)
  expect_equivalent(git_config(bits, where = "local", repo = tpath), exp_out)
  expect_equivalent(git_config_local(bits, repo = tpath), exp_out)
})

test_that("list specific bits of global config", {
  cfg <- read_git_config(file.path("~", ".gitconfig"))
  bits <- c("user.name", "user.email", "core.bare", "nope")
  exp_out <- setNames(cfg[bits], bits)
  expect_equivalent(git_config(bits, where = "global"), exp_out)
  expect_equivalent(git_config_global(bits), exp_out)
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
  expect_equivalent(cfg_1, jenny)
  cfg_2 <- git_config_local(cfg_1, repo = tr)
  expect_equivalent(git_config_local(names(jenny), repo = tr), cfg_1)
})

test_that("calls from outside a repo give sane results", {
  path <- tempfile("githug-test-NOT-A-GIT-REPO-")
  dir.create(path)
  owd <- setwd(path)

  ## can list, but only return global config
  expect_equivalent(git_config(), git_config_global())
  expect_equivalent(git_config(), git_config(where = "global"))
  expect_equivalent(git_config_local(), list())
  expect_equivalent(git_config(where = "local"), list())
  ## local set fails
  expect_error(git_config(color.branch = "never"), "no git repo exists here")
  ## global set works
  expect_is(ocfg <- git_config_global(color.branch = "never"), "list")

  git_config_global(ocfg)
  setwd(owd)
})

test_that("git_config returns objects of class githug_list", {
  ## listing
  expect_is(git_config(), "githug_list")
  ## setting
  tr <- init_tmp_repo()
  cfg_0 <- git_config_local(list(`blah.foo` = "foo"), repo = tr)
  expect_is(cfg_0, "githug_list")
  cfg_1 <- git_config_local(`blah.a` = "a", `blah.b` = "b", repo = tr)
  expect_is(cfg_1, "githug_list")
})

test_that("non-existent var presents as NULL", {
  tr <- init_tmp_repo()
  cfg_0 <- git_config_local(`blah.foo` = "foo", repo = tr)
  expect_equivalent(cfg_0, list(`blah.foo` = NULL))
})

test_that("setting to NULL removes var", {
  tr <- init_tmp_repo()
  l <- list(`blah.foo` = "foo")
  git_config_local(l, repo = tr)
  expect_equivalent(git_config_local("blah.foo", repo = tr), l)
  l["blah.foo"] <- list(NULL)
  git_config_local(l, repo = tr)
  expect_equivalent(git_config_local("blah.foo", repo = tr), l)
})

test_that("NULLs are printed in githug_list object", {
  tr <- init_tmp_repo()
  cfg <- git_config("blah.foo", repo = tr)
  expect_output(print(cfg), "blah.foo = NULL")
})
