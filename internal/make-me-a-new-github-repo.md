make-me-a-new-github-repo.R
================
jenny
Wed Jan 27 14:54:30 2016

``` r
library(githug)

## Example 1:
## create a directory and local repo and remote repo, all at once
## go visit the new thing in the browser
## remove `private = TRUE` if you wish / must
githug_init(path = tempfile("init-test-"), private = TRUE)
```

    ## GitHub personal access token found in env var GITHUB_PAT

    ## GitHub username: jennybc

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpe9xySH/init-test-c31d18522c58

    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpe9xySH/init-test-c31d18522c58

    ## Name of dir / RStudio Project / GitHub repo: init-test-c31d18522c58

    ## Adding RStudio project file to /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/init-test-c31d18522c58

    ## Gitignoring standard R/RStudio files

    ## Creating .gitignore

    ## Adding this to .gitignore:

    ##    .Rproj.user
    ##    .Rhistory
    ##    .RData

    ## Committing ...

    ## [e177e21] 2016-01-27: rstudio init

    ## Storing GitHub username 'jennybc' to local git config var

    ## Creating README.md

    ## Committing ...

    ## [8a5d887] 2016-01-27: add README.md

    ## Listing repos accessible to GitHub user associated with 'pat'

    ## Creating GitHub repo:
    ##   name = init-test-c31d18522c58
    ##   description = R work of staggerin…

    ## Storing GitHub repo info to local git config

    ## Adding remote named 'origin':
    ##   https://github.com/jennybc/init-test-c31d18522c58.git

    ## Pushing to GitHub and setting remote tracking branch

``` r
## Example 2:

## connect a pre-existing Git repo to GitHub
repo <- git_init(tempfile("githug-init-example-"))
```

    ## Creating directory /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpe9xySH/githug-init-example-c31d3add51e1

    ## Doing `git init` in /var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T//Rtmpe9xySH/githug-init-example-c31d3add51e1

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

    ## [5bd4e81] 2016-01-27: thelma is awake

``` r
git_log()
```

    ## Source: local data frame [1 x 7]
    ## 
    ##           message             when author     sha              email
    ##             (chr)            (chr)  (chr)   (chr)              (chr)
    ## 1 thelma is awake 2016-01-27 14:54 thelma 5bd4e81 thelma@example.org
    ## Variables not shown: summary (chr), commit (list).

``` r
## Connect it to GitHub! Visit the new repo in the browser.
githug_init(private = TRUE)
```

    ## GitHub personal access token found in env var GITHUB_PAT

    ## GitHub username: jennybc

    ## 'path' appears to already be a Git repo:
    ## /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/githug-init-example-c31d3add51e1

    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/githug-init-example-c31d3add51e1

    ## Name of dir / RStudio Project / GitHub repo: githug-init-example-c31d3add51e1

    ## Adding RStudio project file to /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/githug-init-example-c31d3add51e1

    ## Gitignoring standard R/RStudio files

    ## Creating .gitignore

    ## Adding this to .gitignore:

    ##    .Rproj.user
    ##    .Rhistory
    ##    .RData

    ## Committing ...

    ## [54f6c7a] 2016-01-27: rstudio init

    ## Storing GitHub username 'jennybc' to local git config var

    ## Creating README.md

    ## Committing ...

    ## [a5cee70] 2016-01-27: add README.md

    ## Listing repos accessible to GitHub user associated with 'pat'

    ## Creating GitHub repo:
    ##   name = githug-init-example-c31d3add51e1
    ##   description = R work of staggerin…

    ## Storing GitHub repo info to local git config

    ## Adding remote named 'origin':
    ##   https://github.com/jennybc/githug-init-example-c31d3add51e1.git

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

    ## [1] "https://github.com/jennybc/githug-init-example-c31d3add51e1.git"

``` r
## see that local master is tracking remote master
git2r::branch_get_upstream(git_HEAD()$git_branch)
```

    ## [a5cee7] (origin @ https://github.com/jennybc/githug-init-example-c31d3add51e1.git) master

``` r
setwd(owd)

## Example 3:
## Turn an existing directory into a Git repo to and connect to GitHub
repo <- tempfile("githug-init-example-")
dir.create(repo)
owd <- setwd(repo)
githug_init(private = TRUE)
```

    ## GitHub personal access token found in env var GITHUB_PAT

    ## GitHub username: jennybc

    ## Doing `git init` in /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/githug-init-example-c31d182aa8f8

    ## Name of dir / RStudio Project / GitHub repo: githug-init-example-c31d182aa8f8

    ## Adding RStudio project file to /private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/Rtmpe9xySH/githug-init-example-c31d182aa8f8

    ## Gitignoring standard R/RStudio files

    ## Creating .gitignore

    ## Adding this to .gitignore:

    ##    .Rproj.user
    ##    .Rhistory
    ##    .RData

    ## Committing ...

    ## [17ab4b3] 2016-01-27: rstudio init

    ## Storing GitHub username 'jennybc' to local git config var

    ## Creating README.md

    ## Committing ...

    ## [564c402] 2016-01-27: add README.md

    ## Listing repos accessible to GitHub user associated with 'pat'

    ## Creating GitHub repo:
    ##   name = githug-init-example-c31d182aa8f8
    ##   description = R work of staggerin…

    ## Storing GitHub repo info to local git config

    ## Adding remote named 'origin':
    ##   https://github.com/jennybc/githug-init-example-c31d182aa8f8.git

    ## Pushing to GitHub and setting remote tracking branch

``` r
setwd(owd)
```
