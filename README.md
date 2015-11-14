<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip) [![](http://www.r-pkg.org/badges/version/githug)](http://www.r-pkg.org/pkg/githug)

<!-- [![Build Status](https://travis-ci.org/jennybc/githug?branch=master)](https://travis-ci.org/jennybc/githug) -->
githug
------

### Welcome to Version Control!

<!--[Demo](https://analovesdotcom.files.wordpress.com/2015/10/voldyhug-1440161473.gif)-->
![Demo](img/voldyhug-1440161473.gif)

Wrap novices and lazy people in the warm embrace of a package that shields you from the pointy bits of Git and GitHub.

#### What exists already? What are the gaps?

-   RStudio's Git client has a few gaps that hurt
    -   cannot create a branch
    -   cannot *set up* anything remote, i.e. create a GitHub remote repo or branch or start tracking a branch
    -   can only set up connection to a remote under narrow circumstances (when cloning from GitHub -- which is why we advocate a "GitHub first" workflow)
    -   cannot associate a local branch with a remote branch, often you start wistfully at greyed out Pull and Push buttons
-   [`gh`](https://github.com/gaborcsardi/gh) package from Gabor Csardi is a very thin wrapper around the GitHub API
    -   user must read API docs to figure out what's possible and then deduce syntax for a `gh` call
    -   no native vectorization
-   *[`rgithub`](https://github.com/cscheid/rgithub/) is another GitHub API wrapper, but seems less suitable as a low-level thing to wrap than `gh`*
-   [`git2r`](https://github.com/ropensci/git2r/) from Stefan Widgren / rOpenSci wraps libgit2, so in theory exposes almost anything you can do from Git via command line
    -   not very novice friendly
    -   *everything* is an S4 object

#### Stuff I want to provide

*use [`purrr`](https://github.com/hadley/purrr) to vectorize and `dplyr`/`tidyr` to `tbl_df`-ize and tidy the returned output*

*strong naming convention*

-   Is Git installed? Where does Git appear to be? Is it on the `PATH`? Obvious connections to `fiasco`.
-   What version of Git?
-   Authentication stuff: set up, query, modify
    -   turn on keychain for HTTPS people
    -   help set up SSH keys and configure ssh-agent
    -   get and stow PAT for GitHub API
-   Global config
    -   user.name
    -   user.email
-   Repos
    -   init
    -   discover
    -   status, log, etc etc
    -   branch
-   Remotes
    -   list
    -   add
    -   delete
    -   rename
-   Interact with GitHub repos
    -   create
    -   delete
    -   create, delete, track branch
    -   push and pull
-   GitHub API
    -   help user figure out what's possible? make this table Gabor and I talk about over in `gh` and put to good use here?
    -   expose fxns to do at least all the stuff I've done via the API

#### Other

[`gitlabr`](http://gitlab.points-of-interest.cc/points-of-interest/gitlabr/issues/): new, nice wrapper around the gitlab API from Jirka Lewandowski.

-   it's "dual" high level and low level. My thing might have a similar feel but where the low-level bits are coming from the packages above?
-   <http://blog.points-of-interest.cc/post/gitlabr-released>
-   <https://cran.r-project.org/web/packages/gitlabr/>

### Installation

HEH. It doesn't exist yet!

``` r
devtools::install_github("jennybc/github")
```
