
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

Load dev version of the package. *This will become `library(githug)`.*

``` r
#library(githug)
devtools::load_all(".")
#> Loading githug
```

Create a new Git repository and set that as working directory for the duration of this example.

``` r
repo <- git_init(tempfile("githug-example-"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … pwoWNc9/githug-example-148d11fac3d3
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … pwoWNc9/githug-example-148d11fac3d3
knitr::opts_knit$set(root.dir = repo)
```

Set (local) config variables for user and email.
Create two files and inspect Git status.

``` r
git_config_local(user.name = "louise", user.email = "louise@example.org")

write("Are these girls real smart or real real lucky?", "max.txt")
write("You get what you settle for.", "louise.txt")
git_status()
#> # A tibble: 2 x 4
#>      status       path change     i
#>       <chr>      <chr>  <chr> <int>
#> 1 untracked louise.txt    new    NA
#> 2 untracked    max.txt    new    NA
```

Commit with `all = TRUE` to automatically accept all current changes. *In interactive use, you get a chance to authorize accept this.*

``` r
git_commit(all = TRUE,
           message = "Brains'll only get you so far and luck always runs out.")
#> Staged these paths:
#>   * louise.txt
#>   * max.txt
#> Commit:
#>   * [a088655] 2016-08-17: Brains'll only get you so far and luck always runs out.
```

Add new file and commit it. Inspect commit history.

``` r
write("Did I hear somebody say \"Peaches\"?", "jimmy.txt")
git_commit("jimmy.txt", message = "That's the code word. I miss you, Peaches.")
#> Staged these paths:
#>   * jimmy.txt
#> Commit:
#>   * [db59a91] 2016-08-17: That's the code word. I miss you, Peaches.
git_history()
#> # A tibble: 2 x 6
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 db59a91 That's the code word. I… 2016-08-17 00:17 louise
#> 2 a088655 Brains'll only get you … 2016-08-17 00:17 louise
#> # ... with 2 more variables: email <chr>, commit <list>
```

Uncommit, i.e. leave files as they are, but go back to parent of current commit.

``` r
git_uncommit(ask = FALSE)
#> Uncommit:
#>   * [db59a91] 2016-08-17: That's the code word. I miss you, Peaches.
#> HEAD now points to:
#>   * [a088655] 2016-08-17: Brains'll only get you so far and luck always runs out.
git_history()
#> # A tibble: 1 x 6
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 a088655 Brains'll only get you … 2016-08-17 00:17 louise
#> # ... with 2 more variables: email <chr>, commit <list>
```

Verify files and staging are OK. Unstage a file.

``` r
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

See history.
Create and checkout a branch. *In an interactive session, you'd get the chance to approve new branch creation.* Go back to master.

``` r
git_history()
#> # A tibble: 1 x 6
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 a088655 Brains'll only get you … 2016-08-17 00:17 louise
#> # ... with 2 more variables: email <chr>, commit <list>
git_branch()
#> [1] "master"
git_switch("new_branch", create = TRUE)
#> Switched to branch:
#>   * new_branch
git_branch()
#> [1] "new_branch"
git_switch()
#> Switched to branch:
#>   * master
git_branch_list()
#> # A tibble: 2 x 6
#>    HEAD  full_name  type     branch remote               gb
#>   <lgl>      <chr> <chr>      <chr>  <chr>           <list>
#> 1  TRUE     master local     master   <NA> <S4: git_branch>
#> 2 FALSE new_branch local new_branch   <NA> <S4: git_branch>
```

Overview of functions
---------------------

| fxn                  | description                                                                  |
|:---------------------|:-----------------------------------------------------------------------------|
| git\_config()        | Get and set Git configuration variables                                      |
| git\_init()          | Create a new repository                                                      |
| git\_status()        | Get status of all files w/r/t Git                                            |
| git\_history()       | Get commit history (a.k.a. the log)                                          |
| git\_stage()         | Stage (changes to) a path for next commit                                    |
| git\_add()           | Synonym for git\_stage()                                                     |
| git\_unstage()       | Unstage (changes to) a path                                                  |
| git\_commit()        | Make a commit                                                                |
| git\_uncommit()      | Undo a Git commit but leave files alone                                      |
| git\_branch()        | Report current branch or list all branches                                   |
| git\_switch()        | Switch to another branch                                                     |
| git\_branch\_\*()    | Lower level functions to list, create, rename, delete, and checkout branches |
| as.git\_repository() | Open a Git repo in the style of the `git2r` package                          |

*to be replaced by a proper test coverage badge*

``` r
Sys.time()
#> [1] "2016-08-17 00:17:34 PDT"
git2r::repository("~/rrr/githug0")
#> Local:    master /Users/jenny/rrr/githug0/
#> Remote:   master @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [790dd1a] 2016-08-17: Branching (#29)
covr::package_coverage("~/rrr/githug0/")
#> githug Coverage: 90.46%
#> R/git_history.R: 66.67%
#> R/git_unstage.R: 75.00%
#> R/git_stage-add.R: 83.08%
#> R/utils.R: 86.79%
#> R/git_branch_create.R: 88.46%
#> R/git_branch_rename.R: 92.86%
#> R/git_commit.R: 93.75%
#> R/git_branch_checkout.R: 96.30%
#> R/git_uncommit.R: 96.55%
#> R/git_branch_delete.R: 100.00%
#> R/git_branch.R: 100.00%
#> R/git_config.R: 100.00%
#> R/git_init.R: 100.00%
#> R/git_repository.R: 100.00%
#> R/git_status.R: 100.00%
#> R/githug_list-class.R: 100.00%
```
