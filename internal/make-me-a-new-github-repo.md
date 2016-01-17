``` r
library(githug)

## Example 1:
## create a directory and local repo and remote repo, all at once
## go visit the new thing in the browser
## remove `private = TRUE` if you wish / must
githug_init(path = tempfile("init-test-"), private = TRUE)
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpiue5C5/init-test-978454b9ea
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpiue5C5/init-test-978454b9ea
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: init-test-978454b9ea
    ## Creating README.md
    ## Committing ...
    ## [ccf8711] 2016-01-17: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/init-test-978454b9ea.git
    ## Pushing to GitHub and setting remote tracking branch

``` r
## Example 2:

## connect a pre-existing Git repo to GitHub
repo <- git_init(tempfile("githug-init-example-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpiue5C5/githug-init-example-9785679b3de
    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpiue5C5/githug-init-example-9785679b3de

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
    ## [84cd1c1] 2016-01-17: thelma is awake

``` r
git_log()
```

    ## Source: local data frame [1 x 7]
    ## 
    ##           message             when author     sha              email
    ##             (chr)            (chr)  (chr)   (chr)              (chr)
    ## 1 thelma is awake 2016-01-17 00:32 thelma 84cd1c1 thelma@example.org
    ## Variables not shown: summary (chr), commit (list).

``` r
## Connect it to GitHub! Visit the new repo in the browser.
githug_init(private = TRUE)
```

    ## 'path' appears to already be a Git repo:
    ## /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpiue5C5/githug-init-example-9785679b3de
    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpiue5C5/githug-init-example-9785679b3de
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: githug-init-example-9785679b3de
    ## Creating README.md
    ## Committing ...
    ## [f78e34f] 2016-01-17: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/githug-init-example-9785679b3de.git
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

    ## [1] "https://github.com/jennybc/githug-init-example-9785679b3de.git"

``` r
## see that local master is tracking remote master
git2r::branch_get_upstream(git_HEAD()$git_branch)
```

    ## [f78e34] (origin @ https://github.com/jennybc/githug-init-example-9785679b3de.git) master

``` r
setwd(owd)

## Example 3:
## Turn an existing directory into a Git repo to and connect to GitHub
repo <- tempfile("githug-init-example-")
dir.create(repo)
owd <- setwd(repo)
githug_init(private = TRUE)
```

    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpiue5C5/githug-init-example-978500fe02c
    ## GitHub personal access token found in env var GITHUB_PAT
    ## GitHub username: jennybc
    ## GitHub repo name: githug-init-example-978500fe02c
    ## Creating README.md
    ## Committing ...
    ## [0d42691] 2016-01-17: add README.md
    ## Adding remote named 'origin':
    ## https://github.com/jennybc/githug-init-example-978500fe02c.git
    ## Pushing to GitHub and setting remote tracking branch

``` r
setwd(owd)
```
