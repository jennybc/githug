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

#' ## Find repo path
#'
#' One motivation of `githug` is to provide an interface to Git operations
#' provided by `git2r` but with an API that is more consistent and more
#' consistently helpful re: identifying the relevant Git repo. I'm inspired by
#' `devtools`, which identifies the target package via its path. The typical
#' user isn't aware of the `package` class. I'd like to similarly downplay
#' `git2r`'s S4 `git_repository` class.
#'
#' This first commit adds internal functions to find and detect repo path:
#'
#' ````
#' user provides info about which repo (consciously or not)
#'   --> githug:::find_repo_path() normalizes it to a path to a repo
#'      --> git2r::repository() turns it into a git_repository
#' that is pre-packaged as githug::as.git_repository()
#' ````
#'
#' The point will be more clear once I bring other functions back.
#'
#' ## Review: git2r functions for identifying a repo
#'
#' The `git2r` functions are somewhat inconsistent in terms of
#'
#'   * whether the default behavior is to consult working directory
#'   * whether `ceiling` can be used to control walking up parents
#'
#' `discover_repository(path, ceiling)`: "used to identify the location of the
#' repository"
#'
#'   * path in, path out
#'   * output path will be like `~/foo/.git/` <-- note the terminating file separator
#'   * `discover_repository()` walks up parents unless `ceiling` is 0 or 1
#'   * DOES NOT default to `"."`; user must always supply a path

setwd(here())         ## make sure wd is pkg root = a git repo
discover_repository() ## too bad this does not default to "."
discover_repository(".")
discover_repository("./tests/testthat")
discover_repository("./tests/testthat", ceiling = 1)
discover_repository("./tests", ceiling = 1)
discover_repository("./tests", ceiling = 0)

#' `repository(path, ...)`: "open a repository"
#'
#'   * path in, `git_repository` object out
#'   * `git2r::init()` also returns such objects
#'   * `repository()` walks up parents to find repo iff `discover = TRUE`
#'   * if `path` not given, DOES consult current working directory
#'   * silently ignores `ceiling`

setwd(here())
repository()                       ## HEY this one does default to repo in wd!
class(repository())
repository("./R")                  ## but it does not walk up, by default
repository("./R", discover = TRUE) ## now we walk
repository("./R", discover = TRUE, ceiling = 0) ## ceiling silently ignored

#' `workdir(repo)` gets "workdir of repository"
#'
#'   * `git_repository` in, path out
#'   * output path will be like `~/foo/`
#'   * if `repo` not given, DOES consult current working directory and walks up
#'     parents to find a git repo

setwd(here())
workdir()                       ## HEY this also defaults to repo in wd!
setwd(file.path(here(), "tests", "testthat"))
workdir()                       ## always walks up

#' ## Usage
#'
#' fiddling around
setwd(here())

find_repo_path()
as.git_repository()
repository()

find_repo_path("./.git")
as.git_repository("./.git")
repository("./.git")

find_repo_path("./R")
find_repo_path("./R", ceiling = 0)
find_repo_path("./R", ceiling = 1)
as.git_repository("./R")
repository("./R")
repository("./R", discover = TRUE)

find_repo_path("./tests/testthat")
find_repo_path("./tests/testthat/", ceiling = 0)
find_repo_path("./tests/testthat/", ceiling = 1)
repository("./tests/testthat/")
repository("./tests/testthat/", discover = TRUE)

find_repo_path("~")
repository("~")

is_in_repo(".")
is_a_repo(".")
is_in_repo("tests/testthat")
is_a_repo("tests/testthat")
is_in_repo("tests/testthat", ceiling = 1)
is_in_repo("~")
is_a_repo("~")
