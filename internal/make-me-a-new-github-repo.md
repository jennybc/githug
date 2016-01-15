``` r
library(githug)

## Example 1:
## create a directory and local repo and remote repo, all at once
## go visit the new thing in the browser
## remove `private = TRUE` if you wish / must
githug_init(path = tempfile("init-test-"), private = TRUE)
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpvqSflU/init-test-1460d770e7ad0
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpvqSflU/init-test-1460d770e7ad0
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: init-test-1460d770e7ad0
    ## Creating README.md
    ## Committing ...
    ## [3f23d03] 2016-01-15: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/init-test-1460d770e7ad0.git
    ## Pushing to GitHub and setting remote tracking branch

``` r
## Example 2:

## connect a pre-existing Git repo to GitHub
repo <- git_init(tempfile("githug-init-example-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpvqSflU/githug-init-example-1460d57a12ac0
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//RtmpvqSflU/githug-init-example-1460d57a12ac0

``` r
## switch working directory to the repo
owd <- setwd(repo)

## Config local git user and make a commit
git_config(user.name = "thelma", user.email = "thelma@example.org")
```

    ## setting local config

``` r
writeLines("I don't ever remember feeling this awake.", "thelma.txt")
git_COMMIT("thelma is awake")
```

    ## Adding files:
    ## thelma.txt
    ## Committing ...
    ## [38dad85] 2016-01-15: thelma is awake

``` r
git_log()
```

    ## Source: local data frame [1 x 7]
    ## 
    ##           message             when author     sha              email
    ##             (chr)            (chr)  (chr)   (chr)              (chr)
    ## 1 thelma is awake 2016-01-15 09:36 thelma 38dad85 thelma@example.org
    ## Variables not shown: summary (chr), commit (list).

``` r
## Connect it to GitHub! Visit the new repo in the browser.
githug_init(private = TRUE)
```

    ## 'path' appears to already be a Git repo:
    ## /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpvqSflU/githug-init-example-1460d57a12ac0
    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpvqSflU/githug-init-example-1460d57a12ac0
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: githug-init-example-1460d57a12ac0
    ## Creating README.md
    ## Committing ...
    ## [9b07442] 2016-01-15: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/githug-init-example-1460d57a12ac0.git
    ## Pushing to GitHub and setting remote tracking branch

``` r
## see that the 'origin' is now set to the GitHub remote
## TO DO: revise this when remote stuff done
git2r::remotes()
```

    ## [1] "origin"

``` r
git2r::remote_url(as_git_repository())
```

    ## [1] "https://github.com/jennybc/githug-init-example-1460d57a12ac0.git"

``` r
## see that local master is tracking remote master
git2r::branch_get_upstream(git_HEAD()$git_branch)
```

    ## NULL

``` r
## TO DO: figure out why this says NULL even though is tracking
## for example, `git remote show origin` shows all is well
## also pull/push greyed out in RStudio
## `git push -u origin master` straightens it out
## it will be satisfying to get to the bottom of this

setwd(owd)

## Example 3:
## Turn an existing directory into a Git repo to and connect to GitHub
repo <- tempfile("githug-init-example-")
dir.create(repo)
owd <- setwd(repo)
githug_init(private = TRUE)
```

    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpvqSflU/githug-init-example-1460d15fdd032
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: githug-init-example-1460d15fdd032
    ## Creating README.md
    ## Committing ...
    ## [43a890d] 2016-01-15: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/githug-init-example-1460d15fdd032.git
    ## Pushing to GitHub and setting remote tracking branch

``` r
setwd(owd)
```
