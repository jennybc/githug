#' ---
#' output:
#'   github_document:
#'     toc: true
#' ---

#+ setup
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
here <- rprojroot::find_package_root_file
library(purrr) # for %>%
devtools::load_all(here())

#' ## Examples from `git_init()`

repo <- git_init(tempfile("git-init-example-"))
## switch working directory to the repo
owd <- setwd(repo)
## Config local user and make a commit
git_config(user.name = "thelma", user.email = "thelma@example.org")
write("I don't ever remember feeling this awake.", "thelma.txt")
git_commit(all = TRUE, message = "thelma is awake")
setwd(owd)

#' ## Examples from `git_status()`

repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)
write("Change me", "change-me")
write("Delete me", "delete-me")
git_status()
git_commit(all = TRUE, message = "first commit")
git_status()
write("OK", "change-me", append = TRUE)
file.remove("delete-me")
write("Add me", "add-me")
git_status()
git_commit(all = TRUE, message = "second commit")
git_status()
setwd(owd)

#' ## Examples from `git_stage()` (practically same as for `git_commit()`)

repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)
write("Are these girls real smart or real real lucky?", "max.txt")
write("You get what you settle for.", "louise.txt")
git_status()
## explicit staging
git_add("max.txt", "louise.txt")
git_status()
write("If done properly armed robbery doesn't have to be a totally unpleasant experience.",
      "jd.txt")
write("Is he your husband or your father?", "louise.txt", append = TRUE)
git_status()
## pre-authorize "stage everything"
git_add(all = TRUE)
git_status()
git_commit(message = "Brains'll only get you so far and luck always runs out.")
git_status()
setwd(owd)

#' ## Some interactive examples re: `git_stage()` and `git_commit()`
#'
#' None of this will be run when rendering, i.e. `eval = FALSE` here.
#+ eval = FALSE

repo <- git_init(tempfile("githug-"))
owd <- setwd(repo)
write("Change me", "change-me")
write("Delete me", "delete-me")
git_status()

## query about staging everything
git_stage() ## say 'yes'

## elicit commit message
git_commit() ## give a message (hello, autocomplete?!?)

write("OK", "change-me", append = TRUE)
file.remove("delete-me")
write("Add me", "add-me")
git_status()

## since nothing is staged, call git_stage() and query
git_commit(message = "second commit")

git_status()
setwd(owd)

