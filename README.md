<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip) [![](http://www.r-pkg.org/badges/version/githug)](http://www.r-pkg.org/pkg/githug)

<!-- [![Build Status](https://travis-ci.org/jennybc/githug?branch=master)](https://travis-ci.org/jennybc/githug) -->
githug
------

### Welcome to Version Control!

<!--[Demo](https://analovesdotcom.files.wordpress.com/2015/10/voldyhug-1440161473.gif)-->
![Demo](img/voldyhug-1440161473.gif)

Wrap yourself in the warm embrace of Git from the comfort of R.

### githug

This package facilitates common Git tasks by gluing together features from [git2r](https://github.com/ropensci/git2r) and [gh](https://github.com/gaborcsardi/gh), with special attention to things you can't do with RStudio's Git client.

I teach "data analysis with R". Alot, often under time constraints, with students running Mac OS, Windows, and Linux. I like to touch on Git and GitHub, but hate to get bogged down in Git-related [command-line bullshittery](http://www.pgbovine.net/command-line-bullshittery.htm). The immediate goal for `githug` is to do basic, mission critical Git/GitHub operations from within R.

### Installation

``` r
devtools::install_github("jennybc/githug")
```

#### Use cases

Basic Git survival kit

-   config
-   init
-   status, log, HEAD
-   add, commit, ADD, COMMIT
-   branch list, create, delete, checkout, CHECKOUT

Connect an existing R project (usually a RStudio Project) to a newly created GitHub remote. See the draft vignette [From R/RStudio to GitHub](vignettes/rstudio-to-github.Rmd).

Authentication help.

-   stow or confirm PAT for GitHub API
-   *TO DO: turn on keychain for HTTPS people? help set up SSH keys and configure ssh-agent?*

Forks. *to do*

-   fork
-   pull fork
-   use git config file and custom config var to record "this repo is a fork of that repo"
-   add fork origin as remote and introduce some convention about name ... fork-origin?
-   **update fork based on fork origin!!!**

More user-facing functions re: GitHub API *to do*

-   help people figure out what's possible?
-   what do I do most? wrap this?
    -   (create | edit | delete | list) \* (repos, teams, issues)

Git support *to do*

-   Is Git installed? Where is it? What version? Is it on the `PATH`?

### The existing landscape

-   [`git2r`](https://github.com/ropensci/git2r/) from Stefan Widgren / rOpenSci wraps libgit2 and is what makes this package possible. In theory, exposes almost anything you can do from Git via command line. Great for programming but rough for use by novice useRs:
    -   there's room to make things easier w/r/t defaults
    -   heavy use of S4 objects as input/output
-   RStudio's Git client is very handy but has a few gaps that hurt: can't create a branch, add a remote, or connect local to remote in general. Once you've got everything setup, it's great for diff, add, commit, push, pull.
-   [`gh`](https://github.com/gaborcsardi/gh) package from Gabor Csardi is a very thin wrapper around the GitHub API. Not suitable for novice use because you must read [API docs](https://developer.github.com/v3/) to figure out what's possible and then deduce syntax for a `gh` call. Also no native vectorization *(but `purrr` works beautifully for this!)*.
-   [`rgithub`](https://github.com/cscheid/rgithub/) is another GitHub API wrapper, but is less low-level than `gh` and therefore less suitable to wrap.
-   [`hub`](https://hub.github.com) command line wrapper for GitHub is inspirational. *Note that the [`gh`](https://github.com/jingweno/gh) command line client has been merged into `hub`.*
-   [`gitlabr`](http://gitlab.points-of-interest.cc/points-of-interest/gitlabr/issues/): nice wrapper around the gitlab API from Jirka Lewandowski. Dual = high level and low level.
    -   <http://blog.points-of-interest.cc/post/gitlabr-released>
    -   <https://cran.r-project.org/web/packages/gitlabr/>
