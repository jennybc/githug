repo-path.R
================
jenny
Thu Aug 4 01:05:32 2016

-   [Find repo path](#find-repo-path)
-   [Review: git2r functions for identifying a repo](#review-git2r-functions-for-identifying-a-repo)
-   [Usage](#usage)

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
here <- rprojroot::find_package_root_file
devtools::load_all(here())
```

    ## Loading githug

``` r
library(git2r)
```

Find repo path
--------------

One motivation of `githug` is to provide an interface to Git operations provided by `git2r` but with an API that is more consistent and more consistently helpful re: identifying the relevant Git repo. I'm inspired by `devtools`, which identifies the target package via its path. The typical user isn't aware of the `package` class. I'd like to similarly downplay `git2r`'s S4 `git_repository` class.

This first commit adds internal functions to find and detect repo path:

    user provides info about which repo (consciously or not)
      --> githug:::find_repo_path() normalizes it to a path to a repo
         --> git2r::repository() turns it into a git_repository
    that is pre-packaged as githug::as.git_repository()

The point will be more clear once I bring other functions back.

Review: git2r functions for identifying a repo
----------------------------------------------

The `git2r` functions are somewhat inconsistent in terms of

-   whether the default behavior is to consult working directory
-   whether `ceiling` can be used to control walking up parents

`discover_repository(path, ceiling)`: "used to identify the location of the repository"

-   path in, path out
-   output path will be like `~/foo/.git/` &lt;-- note the terminating file separator
-   `discover_repository()` walks up parents unless `ceiling` is 0 or 1
-   DOES NOT default to `"."`; user must always supply a path

``` r
setwd(here())         ## make sure wd is pkg root = a git repo
discover_repository() ## too bad this does not default to "."
#> Error in (function (classes, fdef, mtable) : unable to find an inherited method for function 'discover_repository' for signature '"missing", "missing"'
discover_repository(".")
#> [1] "/Users/jenny/rrr/githug0/.git/"
discover_repository("./tests/testthat")
#> [1] "/Users/jenny/rrr/githug0/.git/"
discover_repository("./tests/testthat", ceiling = 1)
#> NULL
discover_repository("./tests", ceiling = 1)
#> [1] "/Users/jenny/rrr/githug0/.git/"
discover_repository("./tests", ceiling = 0)
#> NULL
```

`repository(path, ...)`: "open a repository"

-   path in, `git_repository` object out
-   `git2r::init()` also returns such objects
-   `repository()` walks up parents to find repo iff `discover = TRUE`
-   if `path` not given, DOES consult current working directory
-   silently ignores `ceiling`

``` r
setwd(here())
repository()                       ## HEY this one does default to repo in wd!
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
class(repository())
#> [1] "git_repository"
#> attr(,"package")
#> [1] "git2r"
repository("./R")                  ## but it does not walk up, by default
#> Error in validObject(.Object): invalid class "git_repository" object: Unable to open repository at 'path'
repository("./R", discover = TRUE) ## now we walk
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
repository("./R", discover = TRUE, ceiling = 0) ## ceiling silently ignored
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
```

`workdir(repo)` gets "workdir of repository"

-   `git_repository` in, path out
-   output path will be like `~/foo/`
-   if `repo` not given, DOES consult current working directory and walks up parents to find a git repo

``` r
setwd(here())
workdir()                       ## HEY this also defaults to repo in wd!
#> [1] "/Users/jenny/rrr/githug0/"
setwd(file.path(here(), "tests", "testthat"))
workdir()                       ## always walks up
#> [1] "/Users/jenny/rrr/githug0/"
```

Usage
-----

fiddling around

``` r
setwd(here())

find_repo_path()
#> [1] "/Users/jenny/rrr/githug0"
as.git_repository()
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
repository()
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions

find_repo_path("./.git")
#> [1] "/Users/jenny/rrr/githug0"
as.git_repository("./.git")
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
repository("./.git")
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions

find_repo_path("./R")
#> [1] "/Users/jenny/rrr/githug0"
find_repo_path("./R", ceiling = 0)
#> Error: no git repo exists here:
#> ./R
find_repo_path("./R", ceiling = 1)
#> [1] "/Users/jenny/rrr/githug0"
as.git_repository("./R")
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions
repository("./R")
#> Error in validObject(.Object): invalid class "git_repository" object: Unable to open repository at 'path'
repository("./R", discover = TRUE)
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions

find_repo_path("./tests/testthat")
#> [1] "/Users/jenny/rrr/githug0"
find_repo_path("./tests/testthat/", ceiling = 0)
#> Error: no git repo exists here:
#> ./tests/testthat/
find_repo_path("./tests/testthat/", ceiling = 1)
#> Error: no git repo exists here:
#> ./tests/testthat/
repository("./tests/testthat/")
#> Error in validObject(.Object): invalid class "git_repository" object: Unable to open repository at 'path'
repository("./tests/testthat/", discover = TRUE)
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [fa168c1] 2016-08-03: streamline usage of repo-finding functions

find_repo_path("~")
#> Error: no git repo exists here:
#> ~
repository("~")
#> Error in validObject(.Object): invalid class "git_repository" object: Unable to open repository at 'path'

is_in_repo(".")
#> [1] TRUE
is_a_repo(".")
#> [1] TRUE
is_in_repo("tests/testthat")
#> [1] TRUE
is_a_repo("tests/testthat")
#> [1] FALSE
is_in_repo("tests/testthat", ceiling = 1)
#> [1] FALSE
is_in_repo("~")
#> [1] FALSE
is_a_repo("~")
#> [1] FALSE
```
