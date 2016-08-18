git2r-reset-path-study.R
================
jenny
Tue Aug 9 22:18:16 2016

-   [Verifying what happens with `git2r::reset(object, path)`, where `object`](#verifying-what-happens-with-git2rresetobject-path-where-object)

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

Verifying what happens with `git2r::reset(object, path)`, where `object`
------------------------------------------------------------------------

is a `git_repository`.

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
write("1 one 1 one 1 one FIRST COMMIT", file.path(repo, "a.txt"))
write("I will be deleted", file.path(repo, "b.txt"))
git_commit(all = TRUE, message = "first commit", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#> Commit:
#>   * [5e24d67] 2016-08-09: first commit
readLines(file.path(repo, "a.txt"))
#> [1] "1 one 1 one 1 one FIRST COMMIT"
readLines(file.path(repo, "b.txt"))
#> [1] "I will be deleted"
```

Modify the first file. Delete the second. Create another file.

``` r
write("I'm new in the second commit", file.path(repo, "c.txt"))
file.remove(file.path(repo, "b.txt"))
#> [1] TRUE
write("2 two 2 two 2 two SECOND COMMIT", file.path(repo, "a.txt"),
      append = TRUE)
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
#> 1 one 1 one 1 one FIRST COMMIT
#> 2 two 2 two 2 two SECOND COMMIT
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
#> Warning in file(con, "r"): cannot open file '/Users/jenny/tmp/reset/b.txt':
#> No such file or directory
#> Error in file(con, "r"): cannot open the connection
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
#> I'm new in the second commit
(status_unstaged <- git_status(repo = repo))
#> # A tibble: 3 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1  unstaged a.txt modified    NA
#> 2  unstaged b.txt  deleted    NA
#> 3 untracked c.txt      new    NA
```

Stage all of that.

``` r
git_stage(all = TRUE, repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#>   * c.txt
(status_staged <- git_status(repo = repo))
#> # A tibble: 3 x 4
#>   status  path   change     i
#>    <chr> <chr>    <chr> <int>
#> 1 staged c.txt      new    NA
#> 2 staged a.txt modified    NA
#> 3 staged b.txt  deleted    NA
```

Unstage those paths.

``` r
reset(gr, path = status_staged$path)
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
identical(status_unstaged, status_reset)
#> [1] TRUE
```

Clean up.

``` r
unlink(repo, recursive = TRUE)
```
