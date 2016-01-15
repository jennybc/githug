#' ---
#' output:
#'   md_document:
#'     variant: markdown_github
#' ---

## demo of basic git survival

library(githug)
library(dplyr)

## git config -------------------------

## see git config currently in effect, based on working directory
git_config()         # local > global, same as git_config(where = "de_facto")
git_config_local()   #                 same as git_config(where = "local")
git_config_global()  #                 same as git-config(where = "global")

## set and query global config
(ocfg <-
   git_config_global(user.name = "thelma", user.email = "thelma@example.org"))
git_config_global("user.name", "user.email")
## restore / complete the round trip
git_config_global(ocfg)
git_config_global("user.name", "user.email")

## a whole bunch of adding, commiting, ADDING, and COMMITTING
## conventional git add, status, commit
repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)
writeLines("Are these girls real smart or real real lucky?", "max.txt")
git_add("max.txt")
git_status()
git_commit("Brains'll only get you so far and luck always runs out.")
git_status()
setwd(owd)

## THE SHOUTY COMMANDS
repo <- git_init(tempfile("GITHUG-"))
owd <- setwd(repo)
writeLines("Change me", "change-me")
writeLines("Delete me", "delete-me")
git_status()
git_add(c("change-me", "delete-me"))
git_status()
git_commit("initial")
write("OK", "change-me", append = TRUE)
file.remove("delete-me")
writeLines("Add me", "add-me")
git_status()
git_ADD()
git_status()
## TO DO: return here when commits and reset are wrapped
ccc <- git2r::commits()[[1]]
git2r::reset(ccc, "mixed")
git_status()
git_COMMIT("JUST DO IT.")
git_status()
setwd(owd)

## all the branch things -----------------------
repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)

## no commits --> no branches
git_branch_list()

## commit and ... now we have master
writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
git_COMMIT('1: not in the middle of nowhere')
git_branch_list()
git_branch_list(tips = TRUE)

## create new branch that points at HEAD
git_branch_create("earlybranch")
git_branch_list()

## another commit
write("but we can see it from here.", "nowhere.txt", append = TRUE)
git_COMMIT('2: but we can see it from here')

## create new branch that points at *first commit*, not HEAD
(gl <- git_log())
git_branch_create("hindsight", commit  = gl$commit[[2]])
git_branch_list()
git_branch_list(tips = TRUE)

#+ branch-create-will-error, error = TRUE
## try to re-create an existing branch and fail
git_branch_create("hindsight")

## try try again ... and use the force = TRUE
git_branch_create("hindsight", force = TRUE)
git_branch_list(tips = TRUE)

## checkout an existing branch
git_checkout("earlybranch")
git_branch()
git_HEAD()

## checkout master
git_checkout()
git_HEAD()

## checkout AND CREATE all at once
git_CHECKOUT("IMMEDIATE-GRATIFICATION")
git_HEAD()

## delete a branch
git_branch_delete("earlybranch")
git_branch_list()

setwd(owd)
