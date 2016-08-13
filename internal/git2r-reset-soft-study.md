git2r-reset-soft-study.R
================
jenny
Tue Aug 9 09:04:46 2016

-   [Verifying what happens with soft reset via `git2r::reset()`.](#verifying-what-happens-with-soft-reset-via-git2rreset.)

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

Verifying what happens with soft reset via `git2r::reset()`.
------------------------------------------------------------

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

Check HEAD. Should be `NULL` before the first commit. Points to an "unborn branch".

``` r
head(gr)
#> NULL
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
#>   * [1a9d1c7] 2016-08-09: first commit
readLines(file.path(repo, "a.txt"))
#> [1] "1 one 1 one 1 one FIRST COMMIT"
readLines(file.path(repo, "b.txt"))
#> [1] "I will be deleted"
```

Check HEAD. Now it exists and `git2r::head()` return value is object of S4 class `git_branch`. Check again with `githug:::git_HEAD()`.

``` r
head(gr)
#> [1a9d1c] (Local) (HEAD) master
class(head(gr))
#> [1] "git_branch"
#> attr(,"package")
#> [1] "git2r"
git_HEAD(repo)
#> $commit
#> [1a9d1c7] 2016-08-09: first commit
#> 
#> $message
#> [1] "first commit"
#> 
#> $sha
#> [1] "1a9d1c796aaed06f24a84027b865e0a446e481be"
#> 
#> $branch
#> [1a9d1c] (Local) (HEAD) master
#> 
#> $branch_name
#> [1] "master"
#> 
#> $branch_type
#> [1] "local"
#> 
#> $gr
#> Local:    master /Users/jenny/tmp/reset/
#> Head:     [1a9d1c7] 2016-08-09: first commit
```

Modify the first file. Delete the second. Create two more files. Commit.

``` r
write("I'm new in the second commit", file.path(repo, "c.txt"))
write("I'm also new in the second commit", file.path(repo, "d.txt"))
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
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
#> I'm also new in the second commit
git_status(repo = repo)
#> # A tibble: 4 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1  unstaged a.txt modified    NA
#> 2  unstaged b.txt  deleted    NA
#> 3 untracked c.txt      new    NA
#> 4 untracked d.txt      new    NA
git_commit(all = TRUE, message = "second commit", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * b.txt
#>   * c.txt
#>   * d.txt
#> Commit:
#>   * [1eda753] 2016-08-09: second commit
```

Look at the commit history and check HEAD again. Store the commits for use in resets. Use `githug::git_log()`.

``` r
(commits <- commits(gr))
#> [[1]]
#> [1eda753] 2016-08-09: second commit
#> 
#> [[2]]
#> [1a9d1c7] 2016-08-09: first commit
git_log(repo)
#> # A tibble: 2 x 6
#>       sha                  message             when  author
#>     <chr>                    <chr>            <chr>   <chr>
#> 1 1eda753 second commit            2016-08-09 09:04 jennybc
#> 2 1a9d1c7 first commit             2016-08-09 09:04 jennybc
#> # ... with 2 more variables: email <chr>, commit <list>
```

Which files exist now in the working tree?

``` r
list.files(repo)
#> [1] "a.txt" "c.txt" "d.txt"
```

Make a change to two of the three files but only stage one. Add two more files and stage one.

``` r
write("3 three 3 three 3 three", file.path(repo, "a.txt"), append = TRUE)
write("another line", file.path(repo, "c.txt"), append = TRUE)
write("new after second commit", file.path(repo, "e.txt"))
write("also new after second commit", file.path(repo, "f.txt"))
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
#> 1 one 1 one 1 one FIRST COMMIT
#> 2 two 2 two 2 two SECOND COMMIT
#> 3 three 3 three 3 three
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
#> I'm new in the second commit
#> another line
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
#> I'm also new in the second commit
cat(readLines(file.path(repo, "e.txt")), sep = "\n")
#> new after second commit
cat(readLines(file.path(repo, "f.txt")), sep = "\n")
#> also new after second commit
git_status(repo, ls = TRUE)
#> # A tibble: 5 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1  unstaged a.txt modified    NA
#> 2  unstaged c.txt modified    NA
#> 3 untracked e.txt      new    NA
#> 4 untracked f.txt      new    NA
#> 5   tracked d.txt     none    NA
git_add("a.txt", "e.txt", repo = repo)
#> Staged these paths:
#>   * a.txt
#>   * e.txt
(status_pre_reset <- git_status(repo, ls = TRUE))
#> # A tibble: 5 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1    staged e.txt      new    NA
#> 2    staged a.txt modified    NA
#> 3  unstaged c.txt modified    NA
#> 4 untracked f.txt      new    NA
#> 5   tracked d.txt     none    NA
```

That up right up there ^? That is the status I (sort of) expect to get back to after the reset. In any case, we'll want to compare back to this.

Call `reset()` providing the first commit as a `git_commit` object as the first argument. HEAD will now point to this commit.

``` r
reset(commits[[2]]) # soft is default
list.files(repo)
#> [1] "a.txt" "c.txt" "d.txt" "e.txt" "f.txt"
cat(readLines(file.path(repo, "a.txt")), sep = "\n")
#> 1 one 1 one 1 one FIRST COMMIT
#> 2 two 2 two 2 two SECOND COMMIT
#> 3 three 3 three 3 three
cat(readLines(file.path(repo, "b.txt")), sep = "\n")
#> Warning in file(con, "r"): cannot open file '/Users/jenny/tmp/reset/b.txt':
#> No such file or directory
#> Error in file(con, "r"): cannot open the connection
cat(readLines(file.path(repo, "c.txt")), sep = "\n")
#> I'm new in the second commit
#> another line
cat(readLines(file.path(repo, "d.txt")), sep = "\n")
#> I'm also new in the second commit
cat(readLines(file.path(repo, "e.txt")), sep = "\n")
#> new after second commit
cat(readLines(file.path(repo, "f.txt")), sep = "\n")
#> also new after second commit
```

The working tree has not been changed. Compare current status to that right before the soft reset.

``` r
git_status(repo, ls = TRUE)
#> # A tibble: 7 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1    staged c.txt      new    NA
#> 2    staged d.txt      new    NA
#> 3    staged e.txt      new    NA
#> 4    staged a.txt modified    NA
#> 5    staged b.txt  deleted    NA
#> 6  unstaged c.txt modified    NA
#> 7 untracked f.txt      new    NA
status_pre_reset
#> # A tibble: 5 x 4
#>      status  path   change     i
#>       <chr> <chr>    <chr> <int>
#> 1    staged e.txt      new    NA
#> 2    staged a.txt modified    NA
#> 3  unstaged c.txt modified    NA
#> 4 untracked f.txt      new    NA
#> 5   tracked d.txt     none    NA
```

I used SourceTree to confirm the stuff below as I haven't figured out diff inspection with `git2r`.

-   The accumulated modifications of "a.txt" are staged: the addition of the second and third lines. That makes sense because this is the staged state of "a.txt" at the time of reset.
-   "b.txt" does not exist and its deletion is staged.
-   The creation and first line of "c.txt" is staged (these were part of the commit that disappeared). The addition of the second line of "c.txt" is an unstaged modification, as it was unstaged at the time of reset.
-   The creation of "d.txt" is staged. At the time of reset, it was tracked but unchanged.
-   The creation of "e.txt" is staged.
-   "f.txt" has been created but it is not tracked and unstaged.

``` r
git_HEAD(repo)
#> $commit
#> [1a9d1c7] 2016-08-09: first commit
#> 
#> $message
#> [1] "first commit"
#> 
#> $sha
#> [1] "1a9d1c796aaed06f24a84027b865e0a446e481be"
#> 
#> $branch
#> [1a9d1c] (Local) (HEAD) master
#> 
#> $branch_name
#> [1] "master"
#> 
#> $branch_type
#> [1] "local"
#> 
#> $gr
#> Local:    master /Users/jenny/tmp/reset/
#> Head:     [1a9d1c7] 2016-08-09: first commit
git_log(repo)
#> # A tibble: 1 x 6
#>       sha                  message             when  author
#>     <chr>                    <chr>            <chr>   <chr>
#> 1 1a9d1c7 first commit             2016-08-09 09:04 jennybc
#> # ... with 2 more variables: email <chr>, commit <list>
reflog(gr)
#> [1a9d1c7] HEAD@{0}: reset: moving to 1a9d1c796aaed06f24a84027b865e0a446e481be
#> [1eda753] HEAD@{1}: commit: second commit
#> [1a9d1c7] HEAD@{2}: commit (initial): first commit
```

Yes HEAD is pointing to the requested commit, here the first commit. The second commit disappears from the log. To get it back, you'd need to get it from reflog. So, if this is what `git_uncommit()` comes to mean, will I put something in place -- or message the SHA -- to document which commit has been peeled off? Clean up.

``` r
unlink(repo, recursive = TRUE)
```

Random question: what happens if you reset to a commit is not an ancestor of current HEAD? Leaving this for now.
