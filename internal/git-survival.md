### demo of functions for basic git survival

``` r
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

#### git config

see git config currently in effect, based on working directory

``` r
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

set, query, restore global config

``` r
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
## complete the round trip
git_config_global(ocfg)
git_config_global("user.name", "user.email")
```

    ## $user.name
    ## [1] "jennybc"
    ## 
    ## $user.email
    ## [1] "jenny@stat.ubc.ca"

a whole bunch of adding, commiting, ADDING, and COMMITTING

``` r
## conventional git add, status, commit
repo <- git_init(tempfile("githug-commits-"))
```

    ## Creating directory  /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/githug-commits-17c3051a51c1a
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/githug-commits-17c3051a51c1a

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
    ## [a13de74] 2016-01-16: Brains'll only get you so far and luck always runs out.

``` r
git_status()
```

    ## On branch master

    ## working directory clean

``` r
setwd(owd)
```

**THE SHOUTY COMMANDS**

``` r
repo <- git_init(tempfile("GITHUG-SHOUTING-"))
```

    ## Creating directory  /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/GITHUG-SHOUTING-17c306d46a1a0
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/GITHUG-SHOUTING-17c306d46a1a0

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
    ## [be4f722] 2016-01-16: initial

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
    ## [8b24066] 2016-01-16: JUST DO IT.

``` r
git_status()
```

    ## On branch master

    ## working directory clean

``` r
setwd(owd)
```

all the branch things -----------------------

``` r
repo <- git_init(tempfile("githug-branches-"))
```

    ## Creating directory  /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/githug-branches-17c30a3c203c
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpMQpVJX/githug-branches-17c30a3c203c

``` r
repo
```

    ## [1] "/private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpMQpVJX/githug-branches-17c30a3c203c"

``` r
owd <- setwd(repo)
getwd()
```

    ## [1] "/private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpMQpVJX/githug-branches-17c30a3c203c"

``` r
## **NOTE TO SELF:** I have no idea why this setwd() does not take effect. WTF?
## Temporary workaround: specify repo everywhere below.
```

no commits --&gt; no branches

``` r
git_branch_list(repo = repo)
```

    ## No branches to list.

commit and ... now we have master

``` r
writeLines("Well, we're not in the middle of nowhere...",
           file.path(repo, "nowhere.txt"))
git_COMMIT('1: not in the middle of nowhere', repo = repo)
```

    ## Adding files:
    ## nowhere.txt
    ## Committing ...
    ## [601c6e9] 2016-01-16: 1: not in the middle of nowhere

``` r
git_branch_list(repo = repo)
```

    ## Source: local data frame [1 x 3]
    ## 
    ##     name  type      git_branch
    ##    (chr) (chr)          (list)
    ## 1 master local <S4:git_branch>

``` r
git_branch_list(tips = TRUE, repo = repo)
```

    ## Joining by: "sha"

    ## Source: local data frame [1 x 10]
    ## 
    ##     name  type     sha                  message             when  author
    ##    (chr) (chr)   (chr)                    (chr)            (chr)   (chr)
    ## 1 master local 601c6e9 1: not in the middle of… 2016-01-16 08:48 jennybc
    ## Variables not shown: email (chr), summary (chr), commit (list), git_branch
    ##   (list).

create new branch that points at HEAD

``` r
git_branch_create("earlybranch", repo = repo)
```

    ## Basing new branch on:
    ##   [601c6e] (Local) (HEAD) master
    ## Creating branch earlybranch

``` r
git_branch_list(repo = repo)
```

    ## Source: local data frame [2 x 3]
    ## 
    ##          name  type      git_branch
    ##         (chr) (chr)          (list)
    ## 1 earlybranch local <S4:git_branch>
    ## 2      master local <S4:git_branch>

another commit

``` r
write("but we can see it from here.",
      file.path(repo, "nowhere.txt"), append = TRUE)
git_COMMIT('2: but we can see it from here', repo = repo)
```

    ## Adding files:
    ## nowhere.txt
    ## Committing ...
    ## [5a604b6] 2016-01-16: 2: but we can see it from here

create new branch that points at *first commit*, not HEAD

``` r
(gl <- git_log(repo = repo))
```

    ## Source: local data frame [2 x 7]
    ## 
    ##                    message             when  author     sha
    ##                      (chr)            (chr)   (chr)   (chr)
    ## 1 2: but we can see it fr… 2016-01-16 08:48 jennybc 5a604b6
    ## 2 1: not in the middle of… 2016-01-16 08:48 jennybc 601c6e9
    ## Variables not shown: email (chr), summary (chr), commit (list).

``` r
git_branch_create("hindsight", commit  = gl$commit[[2]], repo = repo)
```

    ## Basing new branch on:
    ##   [601c6e9] 2016-01-16: 1: not in the middle of nowhere
    ## Creating branch hindsight

``` r
git_branch_list(repo = repo)
```

    ## Source: local data frame [3 x 3]
    ## 
    ##          name  type      git_branch
    ##         (chr) (chr)          (list)
    ## 1 earlybranch local <S4:git_branch>
    ## 2   hindsight local <S4:git_branch>
    ## 3      master local <S4:git_branch>

``` r
git_branch_list(tips = TRUE, repo = repo)
```

    ## Joining by: "sha"

    ## Source: local data frame [3 x 10]
    ## 
    ##          name  type     sha                  message             when
    ##         (chr) (chr)   (chr)                    (chr)            (chr)
    ## 1 earlybranch local 601c6e9 1: not in the middle of… 2016-01-16 08:48
    ## 2   hindsight local 601c6e9 1: not in the middle of… 2016-01-16 08:48
    ## 3      master local 5a604b6 2: but we can see it fr… 2016-01-16 08:48
    ## Variables not shown: author (chr), email (chr), summary (chr), commit
    ##   (list), git_branch (list).

try to re-create an existing branch and fail

``` r
git_branch_create("hindsight", repo = repo)
```

    ## Basing new branch on:
    ##   [5a604b] (Local) (HEAD) master

    ## Error in (structure(function (commit, name, force = FALSE) : Error in 'git2r_branch_create': Failed to write reference 'refs/heads/hindsight': a reference with that name already exists.

try try again ... and use the force = TRUE

``` r
git_branch_create("hindsight", force = TRUE, repo = repo)
```

    ## Basing new branch on:
    ##   [5a604b] (Local) (HEAD) master
    ## Creating branch hindsight

``` r
git_branch_list(tips = TRUE, repo = repo)
```

    ## Joining by: "sha"

    ## Source: local data frame [3 x 10]
    ## 
    ##          name  type     sha                  message             when
    ##         (chr) (chr)   (chr)                    (chr)            (chr)
    ## 1 earlybranch local 601c6e9 1: not in the middle of… 2016-01-16 08:48
    ## 2   hindsight local 5a604b6 2: but we can see it fr… 2016-01-16 08:48
    ## 3      master local 5a604b6 2: but we can see it fr… 2016-01-16 08:48
    ## Variables not shown: author (chr), email (chr), summary (chr), commit
    ##   (list), git_branch (list).

checkout an existing branch

``` r
git_checkout("earlybranch", repo = repo)
```

    ## Switched to branch 'earlybranch'

``` r
git_branch(repo = repo)
```

    ## [1] "earlybranch"

``` r
git_HEAD(repo = repo)
```

    ## On branch earlybranch.
    ## Most recent commit:
    ## [601c6e9] 2016-01-16: 1: not in the middle of nowhere

checkout master

``` r
git_checkout(repo = repo)
```

    ## Switched to branch 'master'

``` r
git_HEAD(repo = repo)
```

    ## On branch master.
    ## Most recent commit:
    ## [5a604b6] 2016-01-16: 2: but we can see it from here

checkout AND CREATE all at once

``` r
git_CHECKOUT("IMMEDIATE-GRATIFICATION", repo = repo)
```

    ## Switched to branch 'IMMEDIATE-GRATIFICATION'

``` r
git_HEAD(repo = repo)
```

    ## On branch IMMEDIATE-GRATIFICATION.
    ## Most recent commit:
    ## [5a604b6] 2016-01-16: 2: but we can see it from here

delete a branch

``` r
git_branch_delete("earlybranch", repo = repo)
```

    ## Deleted branch 'earlybranch'

``` r
git_branch_list(repo = repo)
```

    ## Source: local data frame [3 x 3]
    ## 
    ##                      name  type      git_branch
    ##                     (chr) (chr)          (list)
    ## 1               hindsight local <S4:git_branch>
    ## 2 IMMEDIATE-GRATIFICATION local <S4:git_branch>
    ## 3                  master local <S4:git_branch>

``` r
setwd(owd)
```
