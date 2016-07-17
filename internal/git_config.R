#' ---
#' output:
#'   github_document:
#'     toc: true
#' ---

#+ setup
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
here <- rprojroot::find_package_root_file
devtools::load_all(here())
library(git2r)

#' Showing `git_config()` usage

setwd(here())

## see git config currently in effect, based on working directory
git_config()         # local > global, same as git_config(where = "de_facto")
git_config_local()   #                 same as git_config(where = "local")
git_config_global()  #                 same as git_config(where = "global")

## different input formats to list config
git_config_global("user.name", "user.email")
git_config_global(list("user.name", "user.email"))
git_config_global(c("user.name", "user.email"))

## query, set, query, restore, query global config
git_config_global("user.name", "user.email")
ocfg <- git_config_global(user.name = "thelma", user.email = "thelma@example.org")
## guess who's made several commits as thelma in the past :(
git_config_global("user.name", "user.email")
git_config_global(ocfg)
git_config_global("user.name", "user.email")

## specify a Git repo
(repo <- init_tmp_repo(slug = "git-config-demo"))
git_config_local(repo = repo)

## switch working directory to the repo
owd <- setwd(repo)

## set local variables for current repo
git_config_local(user.name = "louise", user.email = "louise@example.org")

## query specific local variables, including a non-existent one
git_config_local("user.name", "color.branch", "user.email")

## make sure we haven't changed global config, should be jenny not louise
git_config_global("user.name", "user.email")

## set local variables, query, restore, query
ocfg <- git_config_local(user.name = "oops", user.email = "oops@example.org")
git_config_local("user.name", "user.email")
git_config_local(ocfg)
git_config_local("user.name", "user.email")

## set a custom variable, query, restore
ocfg <- git_config_local(githug.lol = "wut")
git_config_local("githug.lol")
git_config_local(ocfg)

## restore wd
setwd(owd)
