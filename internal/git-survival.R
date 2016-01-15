#' ---
#' output:
#'   md_document:
#'     variant: markdown_github
#' ---

#' ### demo of functions for basic git survival

library(githug)
library(dplyr)

#' #### git config

#' see git config currently in effect, based on working directory
git_config()         # local > global, same as git_config(where = "de_facto")
git_config_local()   #                 same as git_config(where = "local")
git_config_global()  #                 same as git-config(where = "global")

#' set, query, restore global config
(ocfg <-
   git_config_global(user.name = "thelma", user.email = "thelma@example.org"))
git_config_global("user.name", "user.email")
## complete the round trip
git_config_global(ocfg)
git_config_global("user.name", "user.email")

#' a whole bunch of adding, commiting, ADDING, and COMMITTING
## conventional git add, status, commit
repo <- git_init(tempfile("githug-commits-"))
owd <- setwd(repo)
writeLines("Are these girls real smart or real real lucky?", "max.txt")
git_add("max.txt")
git_status()
git_commit("Brains'll only get you so far and luck always runs out.")
git_status()
setwd(owd)

#' **THE SHOUTY COMMANDS**
repo <- git_init(tempfile("GITHUG-SHOUTING-"))
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

#' all the branch things -----------------------
repo <- git_init(tempfile("githug-branches-"))
repo
owd <- setwd(repo)
getwd()
## **NOTE TO SELF:** I have no idea why this setwd() does not take effect. WTF?
## Temporary workaround: specify repo everywhere below.

#' no commits --> no branches
git_branch_list(repo = repo)

#' commit and ... now we have master
writeLines("Well, we're not in the middle of nowhere...",
           file.path(repo, "nowhere.txt"))
git_COMMIT('1: not in the middle of nowhere', repo = repo)
git_branch_list(repo = repo)
git_branch_list(tips = TRUE, repo = repo)

#' create new branch that points at HEAD
git_branch_create("earlybranch", repo = repo)
git_branch_list(repo = repo)

#' another commit
write("but we can see it from here.",
      file.path(repo, "nowhere.txt"), append = TRUE)
git_COMMIT('2: but we can see it from here', repo = repo)

#' create new branch that points at *first commit*, not HEAD
(gl <- git_log(repo = repo))
git_branch_create("hindsight", commit  = gl$commit[[2]], repo = repo)
git_branch_list(repo = repo)
git_branch_list(tips = TRUE, repo = repo)

#' try to re-create an existing branch and fail
#+ branch-create-will-error, error = TRUE
git_branch_create("hindsight", repo = repo)

#' try try again ... and use the force = TRUE
git_branch_create("hindsight", force = TRUE, repo = repo)
git_branch_list(tips = TRUE, repo = repo)

#' checkout an existing branch
git_checkout("earlybranch", repo = repo)
git_branch(repo = repo)
git_HEAD(repo = repo)

#' checkout master
git_checkout(repo = repo)
git_HEAD(repo = repo)

#' checkout AND CREATE all at once
git_CHECKOUT("IMMEDIATE-GRATIFICATION", repo = repo)
git_HEAD(repo = repo)

#' delete a branch
git_branch_delete("earlybranch", repo = repo)
git_branch_list(repo = repo)

setwd(owd)
