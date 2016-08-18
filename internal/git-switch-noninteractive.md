git-switch-noninteractive.R
================
jenny
Tue Aug 16 22:57:47 2016

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

I need to see what happens when `git_switch()` gets called in a noninteractive session, in order to write the tests.

No commits, no branches.

``` r
tpath <- init_tmp_repo()
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … iaPT2/githug-test-jenny-4ed5a1f23f9
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx … iaPT2/githug-test-jenny-4ed5a1f23f9
git_switch(repo = tpath)
#> No branches to list.
#> 'master' is not the name of any existing local branch.
#> Error: Aborting.
```

Yes a commit, yes a branch exists, but not the one I'm asking for.

``` r
write_file("a", dir = tpath)
git_commit("a", message = "a", repo = tpath)
#> Staged these paths:
#>   * a
#> Commit:
#>   * [18ca18f] 2016-08-16: a
git_switch("b", repo = tpath)
#> 'b' is not the name of any existing local branch.
#> Error: Aborting.
```
