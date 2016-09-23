
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip)

githug
======

### Welcome to Version Control!

<!--[Demo](https://analovesdotcom.files.wordpress.com/2015/10/voldyhug-1440161473.gif)-->
![Demo](img/voldyhug-1440161473.gif)

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
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … Qg3M4c/githug-example-104c22b3c3d11
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … Qg3M4c/githug-example-104c22b3c3d11
knitr::opts_knit$set(root.dir = repo)
```

Set (local) config variables for user and email.
Create two files and inspect Git status.

``` r
git_config_local(user.name = "louise", user.email = "louise@example.org")

write("Are these girls real smart or real real lucky?", "max.txt")
write("You get what you settle for.", "louise.txt")
git_status()
#> Not on a branch.
#> # A tibble: 2 x 4
#>      status       path change     i
#>       <chr>      <chr>  <chr> <int>
#> 1 untracked louise.txt    new    NA
#> 2 untracked    max.txt    new    NA
```

Commit with `all = TRUE` to automatically accept all current changes. *In interactive use, if `all` is unspecified, you get an offer to just stage all current changes.*

``` r
git_commit(all = TRUE,
           message = "Brains'll only get you so far and luck always runs out.")
#> Staged these paths:
#>   * louise.txt
#>   * max.txt
#> Commit:
#>   * [ef9c2d2] 2016-08-29: Brains'll only get you so far and luck always runs out.
```

Add new file and commit it. Inspect commit history.

``` r
write("Did I hear somebody say \"Peaches\"?", "jimmy.txt")
git_commit("jimmy.txt", message = "That's the code word. I miss you, Peaches.")
#> Staged these paths:
#>   * jimmy.txt
#> Commit:
#>   * [5ce96ed] 2016-08-29: That's the code word. I miss you, Peaches.
git_history()
#> # A tibble: 2 x 5
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 5ce96ed That's the code word. I… 2016-08-28 17:11 louise
#> 2 ef9c2d2 Brains'll only get you … 2016-08-28 17:11 louise
#> # ... with 1 more variables: email <chr>
```

Uncommit, i.e. leave files as they are, but go back to parent of current commit.

``` r
git_uncommit(ask = FALSE)
#> Uncommit:
#>   * [5ce96ed] 2016-08-29: That's the code word. I miss you, Peaches.
#> HEAD reset to:
#>   * [ef9c2d2] 2016-08-29: Brains'll only get you so far and luck always runs out.
git_history()
#> # A tibble: 1 x 5
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 ef9c2d2 Brains'll only get you … 2016-08-28 17:11 louise
#> # ... with 1 more variables: email <chr>
```

Verify files and staging are OK. Unstage a file.

``` r
git_status()
#> On branch:
#>   * master
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
#> On branch:
#>   * master
#> # A tibble: 1 x 4
#>      status      path change     i
#>       <chr>     <chr>  <chr> <int>
#> 1 untracked jimmy.txt    new    NA
```

See history.
Create and checkout a branch. *In an interactive session, if `create` is unspecified and branch does not exist, you are asked if you want to create the branch.* Go back to master.

``` r
git_history()
#> # A tibble: 1 x 5
#>       sha                  message             when author
#>     <chr>                    <chr>            <chr>  <chr>
#> 1 ef9c2d2 Brains'll only get you … 2016-08-28 17:11 louise
#> # ... with 1 more variables: email <chr>
git_branch()
#> [1] "master"
git_switch("new_branch", create = TRUE)
#> 'new_branch' is not the name of any existing local branch.
#> New branch 'new_branch' pointed at:
#>   * [ef9c2d2] 2016-08-29: Brains'll only get you so far and luck always runs out.
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
| git\_amend()         | Re-do the most recent commit                                                 |
| git\_file\_rename()  | Rename or move and file and stage it                                         |
| git\_mv()            | Synonym for git\_file\_rename()                                              |
| git\_branch()        | Report current branch or list all branches                                   |
| git\_switch()        | Switch to another branch                                                     |
| git\_branch\_\*()    | Lower level functions to list, create, rename, delete, and checkout branches |
| git\_revision()      | Identify a specific commit                                                   |
| as.git\_repository() | Open a Git repo in the style of the `git2r` package                          |
| as.git\_commit()     | Get a specific commit in the style of the `git2r` package                    |

*to be replaced by a proper test coverage badge*

``` r
Sys.time()
#> [1] "2016-08-29 00:11:16 PDT"
git2r::repository("~/rrr/githug0")
#> Local:    refactor-history /Users/jenny/rrr/githug0/
#> Head:     [2b7f8ff] 2016-08-28: wrap git2r::commits() myself
covr::package_coverage("~/rrr/githug0/")
#> githug Coverage: 87.14%
#> R/git_history.R: 64.00%
#> R/git_unstage.R: 74.55%
#> R/git_amend.R: 76.09%
#> R/git_branch_checkout.R: 76.67%
#> R/git_revision.R: 79.31%
#> R/utils.R: 79.63%
#> R/git_branch_create.R: 81.82%
#> R/git_stage-add.R: 83.08%
#> R/git_file_rename.R: 91.67%
#> R/git_commit.R: 92.11%
#> R/git_branch_rename.R: 92.31%
#> R/git_uncommit.R: 96.77%
#> R/git_as_git_commit.R: 100.00%
#> R/git_branch_delete.R: 100.00%
#> R/git_branch.R: 100.00%
#> R/git_config.R: 100.00%
#> R/git_init.R: 100.00%
#> R/git_repository.R: 100.00%
#> R/git_status.R: 100.00%
#> R/githug_list-class.R: 100.00%
#> R/utils-git2r.R: 100.00%
```
