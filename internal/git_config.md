git\_config.R
================
jenny
Mon Jul 18 15:05:19 2016

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

    ## Warning in setup_ns_exports(pkg, export_all): Objects listed as exports,
    ## but not present in namespace: git_config_list

``` r
library(git2r)
```

Showing `git_config()` usage

``` r
setwd(here())

## see git config currently in effect, based on working directory
git_config()         # local > global, same as git_config(where = "de_facto")
#> core.excludesfile = /Users/jenny/.gitignore_global
#> credential.helper = osxkeychain
#> difftool.sourcetree.cmd = opendiff "$LOCAL" "$REMOTE"
#> difftool.sourcetree.path = 
#> mergetool.sourcetree.cmd = /Applications/SourceTree.app/Contents/Resources/opendiff-w.sh "$LOCAL" "$REMOTE" -ancestor "$BASE" -merge "$MERGED"
#> mergetool.sourcetree.trustexitcode = true
#> pull.ff = only
#> push.default = current
#> user.email = jenny@stat.ubc.ca
#> user.name = jennybc
#> branch.git-config.merge = refs/heads/git-config
#> branch.git-config.remote = origin
#> branch.master.merge = refs/heads/master
#> branch.master.remote = origin
#> core.bare = false
#> core.filemode = true
#> core.ignorecase = true
#> core.logallrefupdates = true
#> core.precomposeunicode = true
#> core.repositoryformatversion = 0
#> remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*
#> remote.origin.url = https://github.com/jennybc/githug0.git
git_config_local()   #                 same as git_config(where = "local")
#> branch.git-config.merge = refs/heads/git-config
#> branch.git-config.remote = origin
#> branch.master.merge = refs/heads/master
#> branch.master.remote = origin
#> core.bare = false
#> core.filemode = true
#> core.ignorecase = true
#> core.logallrefupdates = true
#> core.precomposeunicode = true
#> core.repositoryformatversion = 0
#> remote.origin.fetch = +refs/heads/*:refs/remotes/origin/*
#> remote.origin.url = https://github.com/jennybc/githug0.git
git_config_global()  #                 same as git_config(where = "global")
#> core.excludesfile = /Users/jenny/.gitignore_global
#> credential.helper = osxkeychain
#> difftool.sourcetree.cmd = opendiff "$LOCAL" "$REMOTE"
#> difftool.sourcetree.path = 
#> mergetool.sourcetree.cmd = /Applications/SourceTree.app/Contents/Resources/opendiff-w.sh "$LOCAL" "$REMOTE" -ancestor "$BASE" -merge "$MERGED"
#> mergetool.sourcetree.trustexitcode = true
#> pull.ff = only
#> push.default = current
#> user.email = jenny@stat.ubc.ca
#> user.name = jennybc

## different input formats to get config
git_config_global("user.name", "user.email")
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca
git_config_global(list("user.name", "user.email"))
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca
git_config_global(c("user.name", "user.email"))
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca

## get, set, get, restore, get global config
git_config_global("user.name", "user.email")
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca
ocfg <- git_config_global(user.name = "thelma", user.email = "thelma@example.org")
## guess who's made several commits as thelma in the past :(
git_config_global("user.name", "user.email")
#> user.name = thelma
#> user.email = thelma@example.org
git_config_global(ocfg)
git_config_global("user.name", "user.email")
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca

## specify a Git repo
(repo <- init_tmp_repo(slug = "git-config-demo"))
#> [1] "/private/var/folders/vt/4sdxy0rd1b3b65nqssx4sx_h0000gn/T/RtmpkWlego/git-config-demo-jenny-b46b35816eaf"
git_config_local(repo = repo)
#> core.bare = false
#> core.filemode = true
#> core.ignorecase = true
#> core.logallrefupdates = true
#> core.precomposeunicode = true
#> core.repositoryformatversion = 0

## switch working directory to the repo
owd <- setwd(repo)

## set local variables for current repo
git_config_local(user.name = "louise", user.email = "louise@example.org")

## get specific local variables, including a non-existent one
git_config_local("user.name", "color.branch", "user.email")
#> user.name = louise
#> color.branch = NULL
#> user.email = louise@example.org

## make sure we haven't changed global config, should be jenny not louise
git_config_global("user.name", "user.email")
#> user.name = jennybc
#> user.email = jenny@stat.ubc.ca

## set local variables, get, restore, get
ocfg <- git_config_local(user.name = "oops", user.email = "oops@example.org")
git_config_local("user.name", "user.email")
#> user.name = oops
#> user.email = oops@example.org
git_config_local(ocfg)
git_config_local("user.name", "user.email")
#> user.name = louise
#> user.email = louise@example.org

## set a custom variable, get, restore
ocfg <- git_config_local(githug.lol = "wut")
git_config_local("githug.lol")
#> githug.lol = wut
git_config_local(ocfg)

## restore wd
setwd(owd)
```
