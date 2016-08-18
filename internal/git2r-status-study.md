git2r-status-study.R
================
jenny
Thu Aug 4 18:01:31 2016

-   [Studying `git2r::status()`](#studying-git2rstatus)
-   [Return value of `git2r::status()`](#return-value-of-git2rstatus)
-   [Actual `git_status()` output](#actual-git_status-output)

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
library(purrr)
```

    ## 
    ## Attaching package: 'purrr'

    ## The following objects are masked from 'package:git2r':
    ## 
    ##     is_empty, when

    ## The following object is masked from 'package:githug':
    ## 
    ##     %||%

``` r
suppressMessages(library(dplyr))
library(tidyr)
library(tibble)
```

### Studying `git2r::status()`

I need to know more about the list that `git2r::status()` returns, because I want to turn it into a tibble.

Make a bunch of files and try to leave them in all possible relevant states for `git status`. In the past, I looked at copied files, but there is nothing special about that, so no longer explored. Realized I should have a file that is tracked, gets modified, staged, then modified some more.

``` r
# status: ignored, untracked, tracked, staged, unstaged
# change: none, new, deleted, modified, renamed
(f <- list(status = c("staged", "unstaged"),
           change = c("new", "modified", "deleted", "renamed")) %>%
  expand.grid() %>%
  as.tbl() %>%
  mutate_if(is.factor, as.character) %>%
  add_row(status = "tracked", change = "none") %>%
  ## I want two staged renames
  add_row(status = "staged", change = "renamed") %>%
  ## I'll force add one of these
  add_row(status = "ignored", change = "new") %>%
  add_row(status = "ignored", change = "new") %>%
  ## I'll add this then make another change
  add_row(status = "staged", change = "modified") %>%
  arrange(status, change) %>%
  mutate(name = sub("([a-z]{1,})", "\\1\\1\\1", letters[seq_len(nrow(.))]),
         name = paste(name, status, change, sep = "-")))
#> # A tibble: 13 x 3
#>      status   change                  name
#>       <chr>    <chr>                 <chr>
#> 1   ignored      new       aaa-ignored-new
#> 2   ignored      new       bbb-ignored-new
#> 3    staged  deleted    ccc-staged-deleted
#> 4    staged modified   ddd-staged-modified
#> 5    staged modified   eee-staged-modified
#> 6    staged      new        fff-staged-new
#> 7    staged  renamed    ggg-staged-renamed
#> 8    staged  renamed    hhh-staged-renamed
#> 9   tracked     none      iii-tracked-none
#> 10 unstaged  deleted  jjj-unstaged-deleted
#> 11 unstaged modified kkk-unstaged-modified
#> 12 unstaged      new      lll-unstaged-new
#> 13 unstaged  renamed  mmm-unstaged-renamed
```

Disposable repo.

``` r
path <- git_init(tempfile(pattern = "status-fiddle"))
#> * Creating directory:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpsQbnQ3/status-fiddle147172cfacb1b
#> * Initialising git repository in:
#>   /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpsQbnQ3/status-fiddle147172cfacb1b
repo <- as.git_repository(path)
status(repo)
#> working directory clean
```

Create the files.

``` r
walk(f$name, ~ write(.x, file.path(path, .x)))
dir(path)
#>  [1] "aaa-ignored-new"       "bbb-ignored-new"      
#>  [3] "ccc-staged-deleted"    "ddd-staged-modified"  
#>  [5] "eee-staged-modified"   "fff-staged-new"       
#>  [7] "ggg-staged-renamed"    "hhh-staged-renamed"   
#>  [9] "iii-tracked-none"      "jjj-unstaged-deleted" 
#> [11] "kkk-unstaged-modified" "lll-unstaged-new"     
#> [13] "mmm-unstaged-renamed"
readLines(file.path(path, "ddd-staged-modified"))
#> [1] "ddd-staged-modified"
```

Gitignore file(s).

``` r
write(grep("ignored", f$name, value = TRUE), file.path(path, ".gitignore"))
add(repo, ".gitignore")
commit(repo, "gitignores")
#> [78d5e17] 2016-08-04: gitignores
```

Commit most files, but leave some untracked for later staging.

``` r
(to_add_and_commit <- f %>%
  filter(change %in% c("deleted", "modified", "renamed", "none")) %>%
  .[["name"]])
#> [1] "ccc-staged-deleted"    "ddd-staged-modified"   "eee-staged-modified"  
#> [4] "ggg-staged-renamed"    "hhh-staged-renamed"    "iii-tracked-none"     
#> [7] "jjj-unstaged-deleted"  "kkk-unstaged-modified" "mmm-unstaged-renamed"
add(repo, to_add_and_commit)
commit(repo, "main commit")
#> [1007bb0] 2016-08-04: main commit
status(repo)
#> Untracked files:
#>  Untracked:  fff-staged-new
#>  Untracked:  lll-unstaged-new
```

Make deletions, modifications, and renames.

``` r
(to_delete <- f$name[f$change == "deleted"])
#> [1] "ccc-staged-deleted"   "jjj-unstaged-deleted"
map_lgl(to_delete, ~ file.remove(file.path(path, .x)))
#> [1] TRUE TRUE
(to_modify <- f$name[f$change == "modified"])
#> [1] "ddd-staged-modified"   "eee-staged-modified"   "kkk-unstaged-modified"
walk(to_modify,
     ~ write("another line", file.path(path, .x), append = TRUE))
(to_rename <- f$name[f$change == "renamed"])
#> [1] "ggg-staged-renamed"   "hhh-staged-renamed"   "mmm-unstaged-renamed"
map_lgl(to_rename, ~ file.rename(from = file.path(path, .x),
                                 to = file.path(path, paste0(.x, "-RENAME"))))
#> [1] TRUE TRUE TRUE
```

I think that's all the file system changes needed.

``` r
status(repo)
#> Untracked files:
#>  Untracked:  fff-staged-new
#>  Untracked:  ggg-staged-renamed-RENAME
#>  Untracked:  hhh-staged-renamed-RENAME
#>  Untracked:  lll-unstaged-new
#>  Untracked:  mmm-unstaged-renamed-RENAME
#> 
#> Unstaged changes:
#>  Deleted:    ccc-staged-deleted
#>  Modified:   ddd-staged-modified
#>  Modified:   eee-staged-modified
#>  Deleted:    ggg-staged-renamed
#>  Deleted:    hhh-staged-renamed
#>  Deleted:    jjj-unstaged-deleted
#>  Modified:   kkk-unstaged-modified
#>  Deleted:    mmm-unstaged-renamed
```

Stage stuff

``` r
(to_add <- grep("\\bstaged", dir(path), value = TRUE))
#> [1] "ddd-staged-modified"       "eee-staged-modified"      
#> [3] "fff-staged-new"            "ggg-staged-renamed-RENAME"
#> [5] "hhh-staged-renamed-RENAME"
## grab the deletions and 'from' half of renames
(more_add <- f$name[f$status == "staged"])
#> [1] "ccc-staged-deleted"  "ddd-staged-modified" "eee-staged-modified"
#> [4] "fff-staged-new"      "ggg-staged-renamed"  "hhh-staged-renamed"
add(repo, union(to_add, more_add))
```

Force add one of the gitignored files. Wow, I'm surprised the `add()` above **silently** fails if you omit `force = TRUE`.

``` r
add(repo, grep("ignored-new", f$name, value = TRUE)[1], force = TRUE)
```

Re-modify one of the staged, modified files.

``` r
write("yet another line",
      file.path(path, grep("\\bstaged-modified", f$name, value = TRUE)[1]),
      append = TRUE)
readLines(file.path(path, grep("\\bstaged-modified", f$name, value = TRUE)[1]))
#> [1] "ddd-staged-modified" "another line"        "yet another line"
```

We should have examples of everything now. Below are defaults, except for `ignored = TRUE`. But I want to see that.

``` r
(s <- status(repo, staged = TRUE, unstaged = TRUE, untracked = TRUE,
             ignored = TRUE))
#> Ignored files:
#>  Ignored:    bbb-ignored-new
#> 
#> Untracked files:
#>  Untracked:  lll-unstaged-new
#>  Untracked:  mmm-unstaged-renamed-RENAME
#> 
#> Unstaged changes:
#>  Modified:   ddd-staged-modified
#>  Deleted:    jjj-unstaged-deleted
#>  Modified:   kkk-unstaged-modified
#>  Deleted:    mmm-unstaged-renamed
#> 
#> Staged changes:
#>  New:        aaa-ignored-new
#>  Deleted:    ccc-staged-deleted
#>  Modified:   ddd-staged-modified
#>  Modified:   eee-staged-modified
#>  New:        fff-staged-new
#>  Renamed:    ggg-staged-renamed
#>      Renamed:    ggg-staged-renamed-RENAME
#>  Renamed:    hhh-staged-renamed
#>      Renamed:    hhh-staged-renamed-RENAME
## these better all end in "-RENAME"
setdiff(unlist(s), f$name)
#> [1] "ggg-staged-renamed-RENAME"   "hhh-staged-renamed-RENAME"  
#> [3] "mmm-unstaged-renamed-RENAME"
## should end in "-tracked-none"
setdiff(f$name, unlist(s))
#> [1] "iii-tracked-none"
class(s)
#> [1] "git_status"
methods(class = "git_status")
#> [1] print
#> see '?methods' for accessing help and source code
str(unclass(s))
#> List of 4
#>  $ staged   :List of 7
#>   ..$ new     : chr "aaa-ignored-new"
#>   ..$ deleted : chr "ccc-staged-deleted"
#>   ..$ modified: chr "ddd-staged-modified"
#>   ..$ modified: chr "eee-staged-modified"
#>   ..$ new     : chr "fff-staged-new"
#>   ..$ renamed : chr [1:2] "ggg-staged-renamed" "ggg-staged-renamed-RENAME"
#>   ..$ renamed : chr [1:2] "hhh-staged-renamed" "hhh-staged-renamed-RENAME"
#>  $ unstaged :List of 4
#>   ..$ modified: chr "ddd-staged-modified"
#>   ..$ deleted : chr "jjj-unstaged-deleted"
#>   ..$ modified: chr "kkk-unstaged-modified"
#>   ..$ deleted : chr "mmm-unstaged-renamed"
#>  $ untracked:List of 2
#>   ..$ untracked: chr "lll-unstaged-new"
#>   ..$ untracked: chr "mmm-unstaged-renamed-RENAME"
#>  $ ignored  :List of 1
#>   ..$ ignored: chr "bbb-ignored-new"
```

### Return value of `git2r::status()`

What I think `git2r::status()` returns

-   List with components, potentially
    -   `staged`
    -   `unstaged`
    -   `untracked`
    -   `ignored`
-   Each of those components is a non-uniquely named list of individual paths. The only exception is a staged rename, which holds a length 2 character vector.
-   `staged` can have components with name
    -   `new`
    -   `deleted`
    -   `modified`
    -   `renamed` &lt;-- length 2 character vector, giving 'from' and 'to'
-   `unstaged` can have components with name
    -   `deleted`
    -   `modified`
-   `untracked` can have components with name
    -   `untracked`
-   `ignored` can have components with name
    -   `ignored`
-   A rename is only recognized as such if the deletion and addition are staged, i.e. there is no such thing as an unstaged rename.

### Actual `git_status()` output

Skip to the present. Here's the current output of `git_status()`.

``` r
git_status(path, ls = TRUE)
#> # A tibble: 17 x 4
#>       status                        path       change     i
#>        <chr>                       <chr>        <chr> <int>
#> 1     staged             aaa-ignored-new          new    NA
#> 2     staged              fff-staged-new          new    NA
#> 3     staged         ddd-staged-modified     modified    NA
#> 4     staged         eee-staged-modified     modified    NA
#> 5     staged          ggg-staged-renamed renamed_from     1
#> 6     staged   ggg-staged-renamed-RENAME   renamed_to     1
#> 7     staged          hhh-staged-renamed renamed_from     2
#> 8     staged   hhh-staged-renamed-RENAME   renamed_to     2
#> 9     staged          ccc-staged-deleted      deleted    NA
#> 10  unstaged         ddd-staged-modified     modified    NA
#> 11  unstaged       kkk-unstaged-modified     modified    NA
#> 12  unstaged        jjj-unstaged-deleted      deleted    NA
#> 13  unstaged        mmm-unstaged-renamed      deleted    NA
#> 14 untracked            lll-unstaged-new          new    NA
#> 15 untracked mmm-unstaged-renamed-RENAME          new    NA
#> 16   ignored             bbb-ignored-new          new    NA
#> 17   tracked            iii-tracked-none         none    NA
```
