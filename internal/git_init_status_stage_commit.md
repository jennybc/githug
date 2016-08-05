git\_init\_status\_stage\_commit.R
================
jenny
Fri Aug 5 11:25:01 2016

-   [Examples from `git_init()`](#examples-from-git_init)
-   [Examples from `git_status()`](#examples-from-git_status)
-   [Examples from `git_stage()` (practically same as for `git_commit()`)](#examples-from-git_stage-practically-same-as-for-git_commit)
-   [Some interactive examples re: `git_stage()` and `git_commit()`](#some-interactive-examples-re-git_stage-and-git_commit)

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
here <- rprojroot::find_package_root_file
library(purrr) # for %>%
devtools::load_all(here())
```

    ## Loading githug

Examples from `git_init()`
--------------------------

``` r
repo <- git_init(tempfile("git-init-example-"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/git-init-example-1f446d441707
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/git-init-example-1f446d441707
## switch working directory to the repo
owd <- setwd(repo)
## Config local user and make a commit
git_config(user.name = "thelma", user.email = "thelma@example.org")
#> setting where = "local"
write("I don't ever remember feeling this awake.", "thelma.txt")
git_commit(all = TRUE, message = "thelma is awake")
#> Staged these paths:
#>   * thelma.txt
#> Committing ...
#> [e2781c1] 2016-08-05: thelma is awake
setwd(owd)
```

Examples from `git_status()`
----------------------------

``` r
repo <- git_init(tempfile("githug-"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/githug-1f4488aa69f
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/githug-1f4488aa69f
owd <- setwd(repo)
write("Change me", "change-me")
write("Delete me", "delete-me")
git_status()
#> # A tibble: 2 x 4
#>      status      path change     i
#>       <chr>     <chr>  <chr> <int>
#> 1 untracked change-me    new    NA
#> 2 untracked delete-me    new    NA
git_commit(all = TRUE, message = "first commit")
#> Staged these paths:
#>   * change-me
#>   * delete-me
#> Committing ...
#> [c5ada11] 2016-08-05: first commit
git_status()
#> # A tibble: 0 x 4
#> # ... with 4 variables: status <chr>, path <chr>, change <chr>, i <int>
write("OK", "change-me", append = TRUE)
file.remove("delete-me")
#> [1] TRUE
write("Add me", "add-me")
git_status()
#> # A tibble: 3 x 4
#>      status      path   change     i
#>       <chr>     <chr>    <chr> <int>
#> 1  unstaged change-me modified    NA
#> 2  unstaged delete-me  deleted    NA
#> 3 untracked    add-me      new    NA
git_commit(all = TRUE, message = "second commit")
#> Staged these paths:
#>   * change-me
#>   * delete-me
#>   * add-me
#> Committing ...
#> [abf23c4] 2016-08-05: second commit
git_status()
#> # A tibble: 0 x 4
#> # ... with 4 variables: status <chr>, path <chr>, change <chr>, i <int>
setwd(owd)
```

Examples from `git_stage()` (practically same as for `git_commit()`)
--------------------------------------------------------------------

``` r
repo <- git_init(tempfile("githug-"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/githug-1f442e508240
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpZnXsGP/githug-1f442e508240
owd <- setwd(repo)
write("Are these girls real smart or real real lucky?", "max.txt")
write("You get what you settle for.", "louise.txt")
git_status()
#> # A tibble: 2 x 4
#>      status       path change     i
#>       <chr>      <chr>  <chr> <int>
#> 1 untracked louise.txt    new    NA
#> 2 untracked    max.txt    new    NA
## explicit staging
git_add("max.txt", "louise.txt")
#> Staged these paths:
#>   * louise.txt
#>   * max.txt
git_status()
#> # A tibble: 2 x 4
#>   status       path change     i
#>    <chr>      <chr>  <chr> <int>
#> 1 staged louise.txt    new    NA
#> 2 staged    max.txt    new    NA
write("If done properly armed robbery doesn't have to be a totally unpleasant experience.",
      "jd.txt")
write("Is he your husband or your father?", "louise.txt", append = TRUE)
git_status()
#> # A tibble: 4 x 4
#>      status       path   change     i
#>       <chr>      <chr>    <chr> <int>
#> 1    staged louise.txt      new    NA
#> 2    staged    max.txt      new    NA
#> 3  unstaged louise.txt modified    NA
#> 4 untracked     jd.txt      new    NA
## pre-authorize "stage everything"
git_add(all = TRUE)
#> Staged these paths:
#>   * louise.txt
#>   * jd.txt
git_status()
#> # A tibble: 3 x 4
#>   status       path change     i
#>    <chr>      <chr>  <chr> <int>
#> 1 staged     jd.txt    new    NA
#> 2 staged louise.txt    new    NA
#> 3 staged    max.txt    new    NA
git_commit(message = "Brains'll only get you so far and luck always runs out.")
#> Committing ...
#> [691cb5f] 2016-08-05: Brains'll only get you so far and luck always runs out.
git_status()
#> # A tibble: 0 x 4
#> # ... with 4 variables: status <chr>, path <chr>, change <chr>, i <int>
setwd(owd)
```

Some interactive examples re: `git_stage()` and `git_commit()`
--------------------------------------------------------------

None of this will be run when rendering, i.e. `eval = FALSE` here.

``` r

repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)
write("Change me", "change-me")
write("Delete me", "delete-me")
git_status()

## query about staging everything
git_stage() ## say 'yes'

## elicit commit message
git_commit() ## give a message (hello, autocomplete?!?)

write("OK", "change-me", append = TRUE)
file.remove("delete-me")
write("Add me", "add-me")
git_status()

## since nothing is staged, call git_stage() and query
git_commit(message = "second commit")

git_status()
setwd(owd)
```
