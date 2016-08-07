
<!-- README.md is generated from README.Rmd. Please edit that file -->
*imagine a test coverage badge here*

``` r
Sys.time()
#> [1] "2016-08-06 23:47:51 PDT"
git2r::repository(".")
#> Local:    master /Users/jenny/rrr/githug0/
#> Remote:   master @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [0f60903] 2016-08-06: make long paths fit on one line
covr::package_coverage(".")
#> githug Coverage: 92.91%
#> R/git_add-stage.R: 83.33%
#> R/utils.R: 83.33%
#> R/git_commit.R: 94.44%
#> R/git_config.R: 100.00%
#> R/git_init.R: 100.00%
#> R/git_repository.R: 100.00%
#> R/git_status.R: 100.00%
#> R/githug_list-class.R: 100.00%
```

githug
======

The goal of githug is to wrap you in the warm embrace of Git 🤗, from the comfort of R.

Installation
------------

You can install githug from github with:

``` r
# install.packages("devtools")
devtools::install_github("githug0/jennybc")
```

Example
-------

Create a new Git repository and set local config variables for user and email.

``` r
#library(githug)
devtools::load_all(".")
#> Loading githug

repo <- git_init(tempfile("githug-example-"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … FuJroi/githug-example-156ff6b423b4f
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … FuJroi/githug-example-156ff6b423b4f
setwd(repo)
git_config_local(user.name = "louise", user.email = "louise@example.org")
```

Add two files and inspect Git status.

``` r
setwd(repo) ## necessary because knitr resets wd in every chunk :(

write("Are these girls real smart or real real lucky?", "max.txt")
write("You get what you settle for.", "louise.txt")
git_status()
#> # A tibble: 2 x 4
#>      status       path change     i
#>       <chr>      <chr>  <chr> <int>
#> 1 untracked louise.txt    new    NA
#> 2 untracked    max.txt    new    NA
```

Commit with `all = TRUE` to automatically accept all current changes.

``` r
setwd(repo) ## necessary because knitr resets wd in every chunk :(

git_commit(all = TRUE,
           message = "Brains'll only get you so far and luck always runs out.")
#> Staged these paths:
#>   * louise.txt
#>   * max.txt
#> Committing ...
#> [0eee445] 2016-08-06: Brains'll only get you so far and luck always runs out.
```

Overview of functions
---------------------

| fxn                  | description                                         |
|:---------------------|:----------------------------------------------------|
| git\_config()        | Get and set Git configuration variables             |
| git\_init()          | Create a new repository                             |
| git\_status()        | See status of all files w/r/t Git                   |
| git\_stage()         | Stage (changes to) a path for next commit           |
| git\_add()           | Synonym for git\_stage()                            |
| git\_commit()        | Make a commit                                       |
| as.git\_repository() | Open a Git repo in the style of the `git2r` package |
