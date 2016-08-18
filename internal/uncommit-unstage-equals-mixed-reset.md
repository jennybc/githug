uncommit-unstage-equals-mixed-reset.R
================
jenny
Tue Aug 9 23:06:30 2016

-   [Checking that `githug::uncommit()` + `git_unstage(all = TRUE)` leaves](#checking-that-githuguncommit-git_unstageall-true-leaves)

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
library(git2r)
devtools::session_info("git2r")$packages[1, ]
```

    ##  package * version     date       source                         
    ##  git2r   * 0.15.0.9000 2016-08-09 Github (ropensci/git2r@87b7a9e)

``` r
here <- rprojroot::find_package_root_file
devtools::load_all(here())
```

    ## Loading githug

Checking that `githug::uncommit()` + `git_unstage(all = TRUE)` leaves
---------------------------------------------------------------------

status same as `git2r::reset(<HEAD^>, "mixed")`.

``` r
repo <- file.path("~", "tmp", "reset")
```

Clean up any previous work.

``` r
if (dir.exists(repo)) unlink(repo, recursive = TRUE)
```

Set up a repo.

``` r
repo <- git_init(repo)
#> * Creating directory:
#>   /Users/jenny/tmp/reset
#> * Initialising git repository in:
#>   /Users/jenny/tmp/reset
gr <- as.git_repository(repo)
```

Create 2 files and commit them.

``` r
write("a line 1", file.path(repo, "a.txt"))
write("I will be deleted", file.path(repo, "b.txt"))
git_commit(all = TRUE, message = "first commit", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#> Commit:
#>   * [f5e97db] 2016-08-09: first commit
readLines(file.path(repo, "a.txt"))
#> [1] "a line 1"
readLines(file.path(repo, "b.txt"))
#> [1] "I will be deleted"
```

Modify the first file. Delete the second. Create another file. Commit.

``` r
write("I'm new in the second commit", file.path(repo, "c.txt"))
file.remove(file.path(repo, "b.txt"))
#> [1] TRUE
write("a line 2", file.path(repo, "a.txt"), append = TRUE)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
#> a line 1
#> a line 2
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
#> Warning in file(con, "r"): cannot open file '/Users/jenny/tmp/reset/b.txt':
#> No such file or directory
#> Error in file(con, "r"): cannot open the connection
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
#> I'm new in the second commit
git_commit(all = TRUE, message = "second commit", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#>   * c.txt
#> Commit:
#>   * [c742d21] 2016-08-09: second commit
git_log(repo)
#> # A tibble: 2 x 6
#>       sha                  message             when  author
#>     <chr>                    <chr>            <chr>   <chr>
#> 1 c742d21 second commit            2016-08-09 23:06 jennybc
#> 2 f5e97db first commit             2016-08-09 23:06 jennybc
#> # ... with 2 more variables: email <chr>, commit <list>
```

Uncommit and unstage.

``` r
git_uncommit(repo = repo)
#> Uncommit:
#>   * [c742d21] 2016-08-09: second commit
#> HEAD now points to (but no files were changed!):
#>   * [f5e97db] 2016-08-09: first commit
git_unstage(all = TRUE, repo = repo)
#> Unstaged these paths:
#>   * c.txt
#>   * a.txt
#>   * b.txt
(status_unx2 <- git_status(repo = repo))
#> # A tibble: 3 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1  unstaged a.txt modified    NA
#> 2  unstaged b.txt  deleted    NA
#> 3 untracked c.txt      new    NA
```

Restage and commit.

``` r
git_commit(all = TRUE, message = "second commit, take two", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#>   * c.txt
#> Commit:
#>   * [f4b5253] 2016-08-09: second commit, take two
git_log(repo)
#> # A tibble: 2 x 6
#>       sha                  message             when  author
#>     <chr>                    <chr>            <chr>   <chr>
#> 1 f4b5253 second commit, take two  2016-08-09 23:06 jennybc
#> 2 f5e97db first commit             2016-08-09 23:06 jennybc
#> # ... with 2 more variables: email <chr>, commit <list>
```

Mixed reset.

``` r
reset(git_log(repo)$commit[[2]], reset_type = "mixed")
(status_reset <- git_status(repo = repo))
#> # A tibble: 3 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1  unstaged a.txt modified    NA
#> 2  unstaged b.txt  deleted    NA
#> 3 untracked c.txt      new    NA
```

Is it same as before?

``` r
identical(status_unx2, status_reset)
#> [1] TRUE
```

Clean up.

``` r
unlink(repo, recursive = TRUE)
```
