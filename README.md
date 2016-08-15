
<!-- README.md is generated from README.Rmd. Please edit that file -->
githug
======

The goal of githug is to wrap you in the warm embrace of Git 🤗, from the comfort of R.

*This a reboot of an earlier effort, which lives on in [branch `first-draft`](https://github.com/jennybc/githug/tree/first-draft). That branch includes a function `githug_init()` to connect a new or existing R project (usually a RStudio Project) to a newly created GitHub remote. Currently plodding my way back to that level of functionality.*

Installation
------------

You can install githug from github with:

``` r
# install.packages("devtools")
devtools::install_github("jennybc/githug")
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
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … prenENw/githug-example-f0fa6d5455ea
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … prenENw/githug-example-f0fa6d5455ea
setwd(repo)
git_config_local(user.name = "louise", user.email = "louise@example.org")
```

Create two files and inspect Git status.

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
#> Commit:
#>   * [749ef7d] 2016-08-15: Brains'll only get you so far and luck always runs out.
```

Add new file and commit it. Inspect commit history.

``` r
setwd(repo) ## necessary because knitr resets wd in every chunk :(

write("Did I hear somebody say \"Peaches\"?", "jimmy.txt")
git_commit("jimmy.txt", message = "That's the code word. I miss you, Peaches.")
#> Staged these paths:
#>   * jimmy.txt
#> Commit:
#>   * [9e61003] 2016-08-15: That's the code word. I miss you, Peaches.
git_log()
#> # A tibble: 2 x 6
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 9e61003 That's the code word. I… 2016-08-15 10:27 louise
#> 2 749ef7d Brains'll only get you … 2016-08-15 10:27 louise
#> # ... with 2 more variables: email <chr>, commit <list>
```

Uncommit, i.e. leave files as they are, but go back to parent of current commit.

``` r
setwd(repo) ## necessary because knitr resets wd in every chunk :(

git_uncommit(ask = FALSE)
#> Uncommit:
#>   * [9e61003] 2016-08-15: That's the code word. I miss you, Peaches.
#> HEAD now points to:
#>   * [749ef7d] 2016-08-15: Brains'll only get you so far and luck always runs out.
git_log()
#> # A tibble: 1 x 6
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 749ef7d Brains'll only get you … 2016-08-15 10:27 louise
#> # ... with 2 more variables: email <chr>, commit <list>
```

Verify files and staging are OK. Unstage a file.

``` r
setwd(repo) ## necessary because knitr resets wd in every chunk :(

git_status()
#> # A tibble: 1 x 4
#>   status      path change     i
#>    <chr>     <chr>  <chr> <int>
#> 1 staged jimmy.txt    new    NA
list.files()
#> [1] "jimmy.txt"  "louise.txt" "max.txt"
git_unstage("jimmy.txt")
#> Unstaged these paths:
#>   * jimmy.txt
git_status()
#> # A tibble: 1 x 4
#>      status      path change     i
#>       <chr>     <chr>  <chr> <int>
#> 1 untracked jimmy.txt    new    NA
```

Overview of functions
---------------------

| fxn                  | description                                         |
|:---------------------|:----------------------------------------------------|
| git\_config()        | Get and set Git configuration variables             |
| git\_init()          | Create a new repository                             |
| git\_status()        | Get status of all files w/r/t Git                   |
| git\_log()           | Get commit history                                  |
| git\_stage()         | Stage (changes to) a path for next commit           |
| git\_add()           | Synonym for git\_stage()                            |
| git\_unstage()       | Unstage (changes to) a path                         |
| git\_commit()        | Make a commit                                       |
| git\_uncommit()      | Undo a Git commit but leave files alone             |
| as.git\_repository() | Open a Git repo in the style of the `git2r` package |

*to be replaced by a proper test coverage badge*

``` r
Sys.time()
#> [1] "2016-08-15 10:27:28 PDT"
git2r::repository(".")
#> Local:    master /Users/jenny/rrr/githug0/
#> Remote:   master @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [5a2f493] 2016-08-15: describe "stage it all" options
covr::package_coverage(".")
#> githug Coverage: 88.75%
#> R/git_log.R: 66.67%
#> R/git_unstage.R: 75.00%
#> R/git_stage-add.R: 83.08%
#> R/utils.R: 86.79%
#> R/git_commit.R: 93.75%
#> R/git_uncommit.R: 96.55%
#> R/git_config.R: 100.00%
#> R/git_init.R: 100.00%
#> R/git_repository.R: 100.00%
#> R/git_status.R: 100.00%
#> R/githug_list-class.R: 100.00%
```
