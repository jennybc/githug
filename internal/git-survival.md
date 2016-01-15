``` r
## demo of basic git survival

library(githug)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'
    ## 
    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
## git config -------------------------

## see git config currently in effect, based on working directory
git_config()         # local > global, same as git_config(where = "de_facto")
```

    ## $core.excludesfile
    ## [1] "/Users/jenny/.gitignore_global"
    ## 
    ## $credential.helper
    ## [1] "osxkeychain"
    ## 
    ## $difftool.sourcetree.cmd
    ## [1] "opendiff \"$LOCAL\" \"$REMOTE\""
    ## 
    ## $difftool.sourcetree.path
    ## [1] ""
    ## 
    ## $mergetool.sourcetree.cmd
    ## [1] "/Applications/SourceTree.app/Contents/Resources/opendiff-w.sh \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\""
    ## 
    ## $mergetool.sourcetree.trustexitcode
    ## [1] "true"
    ## 
    ## $user.email
    ## [1] "jenny@stat.ubc.ca"
    ## 
    ## $user.name
    ## [1] "jennybc"
    ## 
    ## $a.a
    ## [1] "a"
    ## 
    ## $branch.master.merge
    ## [1] "refs/heads/master"
    ## 
    ## $branch.master.remote
    ## [1] "origin"
    ## 
    ## $core.bare
    ## [1] "false"
    ## 
    ## $core.filemode
    ## [1] "true"
    ## 
    ## $core.ignorecase
    ## [1] "true"
    ## 
    ## $core.logallrefupdates
    ## [1] "true"
    ## 
    ## $core.precomposeunicode
    ## [1] "true"
    ## 
    ## $core.repositoryformatversion
    ## [1] "0"
    ## 
    ## $githug.user
    ## [1] "jennybc"
    ## 
    ## $remote.origin.fetch
    ## [1] "+refs/heads/*:refs/remotes/origin/*"
    ## 
    ## $remote.origin.url
    ## [1] "https://github.com/jennybc/githug.git"

``` r
git_config_local()   #                 same as git_config(where = "local")
```

    ## $a.a
    ## [1] "a"
    ## 
    ## $branch.master.merge
    ## [1] "refs/heads/master"
    ## 
    ## $branch.master.remote
    ## [1] "origin"
    ## 
    ## $core.bare
    ## [1] "false"
    ## 
    ## $core.filemode
    ## [1] "true"
    ## 
    ## $core.ignorecase
    ## [1] "true"
    ## 
    ## $core.logallrefupdates
    ## [1] "true"
    ## 
    ## $core.precomposeunicode
    ## [1] "true"
    ## 
    ## $core.repositoryformatversion
    ## [1] "0"
    ## 
    ## $githug.user
    ## [1] "jennybc"
    ## 
    ## $remote.origin.fetch
    ## [1] "+refs/heads/*:refs/remotes/origin/*"
    ## 
    ## $remote.origin.url
    ## [1] "https://github.com/jennybc/githug.git"
    ## 
    ## $user.name
    ## [1] "jennybc"

``` r
git_config_global()  #                 same as git-config(where = "global")
```

    ## $core.excludesfile
    ## [1] "/Users/jenny/.gitignore_global"
    ## 
    ## $credential.helper
    ## [1] "osxkeychain"
    ## 
    ## $difftool.sourcetree.cmd
    ## [1] "opendiff \"$LOCAL\" \"$REMOTE\""
    ## 
    ## $difftool.sourcetree.path
    ## [1] ""
    ## 
    ## $mergetool.sourcetree.cmd
    ## [1] "/Applications/SourceTree.app/Contents/Resources/opendiff-w.sh \"$LOCAL\" \"$REMOTE\" -ancestor \"$BASE\" -merge \"$MERGED\""
    ## 
    ## $mergetool.sourcetree.trustexitcode
    ## [1] "true"
    ## 
    ## $user.email
    ## [1] "jenny@stat.ubc.ca"
    ## 
    ## $user.name
    ## [1] "jennybc"

``` r
## set and query global config
(ocfg <-
   git_config_global(user.name = "thelma", user.email = "thelma@example.org"))
```

    ## $user.name
    ## [1] "jennybc"
    ## 
    ## $user.email
    ## [1] "jenny@stat.ubc.ca"

``` r
git_config_global("user.name", "user.email")
```

    ## $user.name
    ## [1] "thelma"
    ## 
    ## $user.email
    ## [1] "thelma@example.org"

``` r
## restore / complete the round trip
git_config_global(ocfg)
git_config_global("user.name", "user.email")
```

    ## $user.name
    ## [1] "jennybc"
    ## 
    ## $user.email
    ## [1] "jenny@stat.ubc.ca"

``` r
## a whole bunch of adding, commiting, ADDING, and COMMITTING
## conventional git add, status, commit
repo <- git_init(tempfile("githug-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/githug-1477363d1be24
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/githug-1477363d1be24

``` r
owd <- setwd(repo)
writeLines("Are these girls real smart or real real lucky?", "max.txt")
git_add("max.txt")
git_status()
```

    ## On branch

    ## Staged changes:
    ##  New:        max.txt

``` r
git_commit("Brains'll only get you so far and luck always runs out.")
```

    ## Committing ...
    ## [ba09737] 2016-01-15: Brains'll only get you so far and luck always runs out.

``` r
git_status()
```

    ## On branch master

    ## working directory clean

``` r
setwd(owd)

## THE SHOUTY COMMANDS
repo <- git_init(tempfile("GITHUG-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/GITHUG-147735f1a60ae
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/GITHUG-147735f1a60ae

``` r
owd <- setwd(repo)
writeLines("Change me", "change-me")
writeLines("Delete me", "delete-me")
git_status()
```

    ## On branch

    ## Untracked files:
    ##  Untracked:  change-me
    ##  Untracked:  delete-me

``` r
git_add(c("change-me", "delete-me"))
git_status()
```

    ## On branch

    ## Staged changes:
    ##  New:        change-me
    ##  New:        delete-me

``` r
git_commit("initial")
```

    ## Committing ...
    ## [2c420a6] 2016-01-15: initial

``` r
write("OK", "change-me", append = TRUE)
file.remove("delete-me")
```

    ## [1] TRUE

``` r
writeLines("Add me", "add-me")
git_status()
```

    ## On branch master

    ## Untracked files:
    ##  Untracked:  add-me
    ## 
    ## Unstaged changes:
    ##  Modified:   change-me
    ##  Deleted:    delete-me

``` r
git_ADD()
```

    ## Adding files:
    ## change-me
    ## delete-me
    ## add-me

``` r
git_status()
```

    ## On branch master

    ## Staged changes:
    ##  New:        add-me
    ##  Modified:   change-me
    ##  Deleted:    delete-me

``` r
## TO DO: return here when commits and reset are wrapped
ccc <- git2r::commits()[[1]]
git2r::reset(ccc, "mixed")
git_status()
```

    ## On branch master

    ## Untracked files:
    ##  Untracked:  add-me
    ## 
    ## Unstaged changes:
    ##  Modified:   change-me
    ##  Deleted:    delete-me

``` r
git_COMMIT("JUST DO IT.")
```

    ## Adding files:
    ## change-me
    ## delete-me
    ## add-me
    ## Committing ...
    ## [6279120] 2016-01-15: JUST DO IT.

``` r
git_status()
```

    ## On branch master

    ## working directory clean

``` r
setwd(owd)

## all the branch things -----------------------
repo <- git_init(tempfile("githug-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/githug-147733cc17049
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpaMJofs/githug-147733cc17049

``` r
owd <- setwd(repo)

## no commits --> no branches
git_branch_list()
```

    ## No branches to list.

``` r
## commit and ... now we have master
writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
git_COMMIT('1: not in the middle of nowhere')
```

    ## Adding files:
    ## nowhere.txt
    ## Committing ...
    ## [744f898] 2016-01-15: 1: not in the middle of nowhere

``` r
git_branch_list()
```

    ## Source: local data frame [1 x 3]
    ## 
    ##     name  type      git_branch
    ##    (chr) (chr)          (list)
    ## 1 master local <S4:git_branch>

``` r
git_branch_list(tips = TRUE)
```

    ## Joining by: "sha"

    ## Source: local data frame [1 x 10]
    ## 
    ##     name  type     sha                  message             when  author
    ##    (chr) (chr)   (chr)                    (chr)            (chr)   (chr)
    ## 1 master local 744f898 1: not in the middle of… 2016-01-15 09:48 jennybc
    ## Variables not shown: email (chr), summary (chr), commit (list), git_branch
    ##   (list).

``` r
## create new branch that points at HEAD
git_branch_create("earlybranch")
```

    ## Basing new branch on:
    ##   [744f89] (Local) (HEAD) master
    ## Creating branch earlybranch

``` r
git_branch_list()
```

    ## Source: local data frame [2 x 3]
    ## 
    ##          name  type      git_branch
    ##         (chr) (chr)          (list)
    ## 1 earlybranch local <S4:git_branch>
    ## 2      master local <S4:git_branch>

``` r
## another commit
write("but we can see it from here.", "nowhere.txt", append = TRUE)
git_COMMIT('2: but we can see it from here')
```

    ## Adding files:
    ## nowhere.txt
    ## Committing ...
    ## [8edf81d] 2016-01-15: 2: but we can see it from here

``` r
## create new branch that points at *first commit*, not HEAD
(gl <- git_log())
```

    ## Source: local data frame [2 x 7]
    ## 
    ##                    message             when  author     sha
    ##                      (chr)            (chr)   (chr)   (chr)
    ## 1 2: but we can see it fr… 2016-01-15 09:48 jennybc 8edf81d
    ## 2 1: not in the middle of… 2016-01-15 09:48 jennybc 744f898
    ## Variables not shown: email (chr), summary (chr), commit (list).

``` r
git_branch_create("hindsight", commit  = gl$commit[[2]])
```

    ## Basing new branch on:
    ##   [744f898] 2016-01-15: 1: not in the middle of nowhere
    ## Creating branch hindsight

``` r
git_branch_list()
```

    ## Source: local data frame [3 x 3]
    ## 
    ##          name  type      git_branch
    ##         (chr) (chr)          (list)
    ## 1 earlybranch local <S4:git_branch>
    ## 2   hindsight local <S4:git_branch>
    ## 3      master local <S4:git_branch>

``` r
git_branch_list(tips = TRUE)
```

    ## Joining by: "sha"

    ## Source: local data frame [3 x 10]
    ## 
    ##          name  type     sha                  message             when
    ##         (chr) (chr)   (chr)                    (chr)            (chr)
    ## 1 earlybranch local 744f898 1: not in the middle of… 2016-01-15 09:48
    ## 2   hindsight local 744f898 1: not in the middle of… 2016-01-15 09:48
    ## 3      master local 8edf81d 2: but we can see it fr… 2016-01-15 09:48
    ## Variables not shown: author (chr), email (chr), summary (chr), commit
    ##   (list), git_branch (list).

``` r
## try to re-create an existing branch and fail
git_branch_create("hindsight")
```

    ## Basing new branch on:
    ##   [9c4077] (Local) (HEAD) IMMEDIATE-GRATIFICATION

    ## Error in (structure(function (commit, name, force = FALSE) : Error in 'git2r_branch_create': Failed to write reference 'refs/heads/hindsight': a reference with that name already exists.

``` r
## try try again ... and use the force = TRUE
git_branch_create("hindsight", force = TRUE)
```

    ## Basing new branch on:
    ##   [9c4077] (Local) (HEAD) IMMEDIATE-GRATIFICATION
    ## Creating branch hindsight

``` r
git_branch_list(tips = TRUE)
```

    ## Joining by: "sha"

    ## Source: local data frame [5 x 10]
    ## 
    ##                      name   type     sha                  message
    ##                     (chr)  (chr)   (chr)                    (chr)
    ## 1               hindsight  local 9c4077b githug_init ... "it wor…
    ## 2 IMMEDIATE-GRATIFICATION  local 9c4077b githug_init ... "it wor…
    ## 3                  master  local 9c4077b githug_init ... "it wor…
    ## 4             origin/HEAD remote      NA                       NA
    ## 5           origin/master remote 9c4077b githug_init ... "it wor…
    ## Variables not shown: when (chr), author (chr), email (chr), summary (chr),
    ##   commit (list), git_branch (list).

``` r
## checkout an existing branch
git_checkout("earlybranch")
```

    ## Error: 'earlybranch' does not match any of the known local branches:
    ## hindsight
    ## IMMEDIATE-GRATIFICATION
    ## master

``` r
git_branch()
```

    ## [1] "IMMEDIATE-GRATIFICATION"

``` r
git_HEAD()
```

    ## On branch IMMEDIATE-GRATIFICATION.
    ## Most recent commit:
    ## [9c4077b] 2016-01-13: githug_init ... "it works for me!"

``` r
## checkout master
git_checkout()
```

    ## Switched to branch 'master'

``` r
git_HEAD()
```

    ## On branch master.
    ## Most recent commit:
    ## [9c4077b] 2016-01-13: githug_init ... "it works for me!"

``` r
## checkout AND CREATE all at once
git_CHECKOUT("IMMEDIATE-GRATIFICATION")
```

    ## Switched to branch 'IMMEDIATE-GRATIFICATION'

``` r
git_HEAD()
```

    ## On branch IMMEDIATE-GRATIFICATION.
    ## Most recent commit:
    ## [9c4077b] 2016-01-13: githug_init ... "it works for me!"

``` r
## delete a branch
git_branch_delete("earlybranch")
```

    ## Error: 'earlybranch' does not match any of the known local branches:
    ## hindsight
    ## IMMEDIATE-GRATIFICATION
    ## master

``` r
git_branch_list()
```

    ## Source: local data frame [5 x 3]
    ## 
    ##                      name   type      git_branch
    ##                     (chr)  (chr)          (list)
    ## 1               hindsight  local <S4:git_branch>
    ## 2 IMMEDIATE-GRATIFICATION  local <S4:git_branch>
    ## 3                  master  local <S4:git_branch>
    ## 4             origin/HEAD remote <S4:git_branch>
    ## 5           origin/master remote <S4:git_branch>

``` r
setwd(owd)
```
