#' ---
#' output: github_document
#' ---

library(githug)

## Example 1:
## create a directory and local repo and remote repo, all at once
## go visit the new thing in the browser
## remove `private = TRUE` if you wish / must
githug_init(path = tempfile("init-test-"), private = TRUE)

## Example 2:

## connect a pre-existing Git repo to GitHub
repo <- git_init(tempfile("githug-init-example-"))

## switch working directory to the repo
owd <- setwd(repo)

## Config local git user and make a commit
git_config(user.name = "thelma", user.email = "thelma@example.org")
writeLines("I don't ever remember feeling this awake.", "thelma.txt")
git_COMMIT("thelma is awake")
git_log()

## Connect it to GitHub! Visit the new repo in the browser.
githug_init(private = TRUE)

## see that the 'origin' is now set to the GitHub remote
## TO DO: revise this when remote stuff done
git2r::remotes()
git2r::remote_url(as_git_repository())

## see that local master is tracking remote master
git2r::branch_get_upstream(git_HEAD()$git_branch)

setwd(owd)

## Example 3:
## Turn an existing directory into a Git repo to and connect to GitHub
repo <- tempfile("githug-init-example-")
dir.create(repo)
owd <- setwd(repo)
githug_init(private = TRUE)
setwd(owd)
