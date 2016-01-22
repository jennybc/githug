<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip) [![](http://www.r-pkg.org/badges/version/githug)](http://www.r-pkg.org/pkg/githug)[![Travis-CI Build Status](https://travis-ci.org/jennybc/githug.svg?branch=master)](https://travis-ci.org/jennybc/githug)

<!-- [![Build Status](https://travis-ci.org/jennybc/githug?branch=master)](https://travis-ci.org/jennybc/githug) -->
githug
------

### Welcome to Version Control!

<!--[Demo](https://analovesdotcom.files.wordpress.com/2015/10/voldyhug-1440161473.gif)-->
![Demo](img/voldyhug-1440161473.gif)

Wrap yourself in the warm embrace of Git from the comfort of R.

### githug

This package facilitates common Git tasks by gluing together features from [git2r](https://github.com/ropensci/git2r) and [gh](https://github.com/gaborcsardi/gh), with special attention to things you can't do with RStudio's Git client.

What's the point?

-   **Use in teaching:** I teach "data analysis with R". Alot, under time constraints, with students running Mac OS, Windows, and Linux. I like to touch on Git and GitHub, but hate to get bogged down in Git-related [command-line bullshittery](http://www.pgbovine.net/command-line-bullshittery.htm). An immediate goal for `githug` is to do basic, mission critical Git/GitHub operations from within R, with minimal fuss. I'd like to write lessons more easily, i.e. stay in R and avoid writing "Mac OS: do this, Windows: do that, ...".
-   **Selfishness:** There are a few things I do often that I wish were even easier. Karthik and Scott told me about the [`hub`](https://hub.github.com) command line tool, which has a few commands worth imitating, e.g., `hub create` and `hub browse`.

### Installation

*this is really really a work in progress, so just know that*

*current quality level = "it works for me"*

``` r
devtools::install_github("jennybc/githug")
```

#### What can you do with it?

Basic Git survival. *See lots of compiled examples here: [`git-survival`](https://github.com/jennybc/githug/blob/master/internal/git-survival.md)*

-   config
-   init
-   status, log, HEAD
-   add, commit, ADD, COMMIT
-   branch list, create, delete, checkout, CHECKOUT
-   *to do: remotes, initiate branch tracking after-the-fact*

Connect a new or existing R project (usually a RStudio Project) to a newly created GitHub remote.

``` r
library(githug)
## remove `private = TRUE` if you wish / must
githug_init(path = tempfile("githug-loves-me-"), private = TRUE)`
```

-   See 3 worked examples here: [`make-me-a-new-github-repo`](https://github.com/jennybc/githug/blob/master/internal/make-me-a-new-github-repo.md)
-   Motivation recorded in a draft vignette [From R/RStudio to GitHub](vignettes/rstudio-to-github.Rmd) for notes.

Forks. *to do*

-   fork, pull
-   record the fork relationship in local git config so we can make it easier for novices to ...
-   **update fork based on fork origin!!!**

GitHub API operations. *to do*

-   wrap and vectorize the `gh` calls for of the most common tasks
    -   (create | edit | delete | list) \* (repos, teams, issues)

*Git diagnostic support for teaching?*

-   Is Git installed? Where is it? What version? Is it on the `PATH`?

*Authentication help?*

-   store PAT for GitHub API into `.Renviron`?
-   help setting up ssh keys? configure ssh-agent?

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
