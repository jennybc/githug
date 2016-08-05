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
devtools::load_all(here())
library(git2r)
library(purrr)
suppressMessages(library(dplyr))
library(tidyr)
library(tibble)

#' ### Studying `git2r::status()`
#'
#' I need to know more about the list that `git2r::status()` returns, because I
#' want to turn it into a tibble.
#'
#' Make a bunch of files and try to leave them in all possible relevant states
#' for `git status`. In the past, I looked at copied files, but there is nothing
#' special about that, so no longer explored. Realized I should have a file that
#' is tracked, gets modified, staged, then modified some more.
# status: ignored, untracked, tracked, staged, unstaged
# change: none, new, deleted, modified, renamed
(f <- list(status = c("staged", "unstaged"),
           change = c("new", "modified", "deleted", "renamed")) %>%
  expand.grid() %>%
  as.tbl() %>%
  mutate_if(is.factor, as.character) %>%
  add_row(status = "tracked", change = "none") %>%
  ## I want two staged renames
  add_row(status = "staged", change = "renamed") %>%
  ## I'll force add one of these
  add_row(status = "ignored", change = "new") %>%
  add_row(status = "ignored", change = "new") %>%
  ## I'll add this then make another change
  add_row(status = "staged", change = "modified") %>%
  arrange(status, change) %>%
  mutate(name = sub("([a-z]{1,})", "\\1\\1\\1", letters[seq_len(nrow(.))]),
         name = paste(name, status, change, sep = "-")))

#' Disposable repo.
path <- git_init(tempfile(pattern = "status-fiddle"))
repo <- as.git_repository(path)
status(repo)

#' Create the files.
walk(f$name, ~ write(.x, file.path(path, .x)))
dir(path)
readLines(file.path(path, "ddd-staged-modified"))

#' Gitignore file(s).
write(grep("ignored", f$name, value = TRUE), file.path(path, ".gitignore"))
add(repo, ".gitignore")
commit(repo, "gitignores")

#' Commit most files, but leave some untracked for later staging.
(to_add_and_commit <- f %>%
  filter(change %in% c("deleted", "modified", "renamed", "none")) %>%
  .[["name"]])
add(repo, to_add_and_commit)
commit(repo, "main commit")
status(repo)

#' Make deletions, modifications, and renames.
(to_delete <- f$name[f$change == "deleted"])
map_lgl(to_delete, ~ file.remove(file.path(path, .x)))
(to_modify <- f$name[f$change == "modified"])
walk(to_modify,
     ~ write("another line", file.path(path, .x), append = TRUE))
(to_rename <- f$name[f$change == "renamed"])
map_lgl(to_rename, ~ file.rename(from = file.path(path, .x),
                                 to = file.path(path, paste0(.x, "-RENAME"))))

#' I think that's all the file system changes needed.
status(repo)

#' Stage stuff
(to_add <- grep("\\bstaged", dir(path), value = TRUE))
## grab the deletions and 'from' half of renames
(more_add <- f$name[f$status == "staged"])
add(repo, union(to_add, more_add))

#' Force add one of the gitignored files. Wow, I'm surprised the `add()` above
#' **silently** fails if you omit `force = TRUE`.
add(repo, grep("ignored-new", f$name, value = TRUE)[1], force = TRUE)

#' Re-modify one of the staged, modified files.
write("yet another line",
      file.path(path, grep("\\bstaged-modified", f$name, value = TRUE)[1]),
      append = TRUE)
readLines(file.path(path, grep("\\bstaged-modified", f$name, value = TRUE)[1]))

#' We should have examples of everything now. Below are defaults, except for
#' `ignored = TRUE`. But I want to see that.
(s <- status(repo, staged = TRUE, unstaged = TRUE, untracked = TRUE,
             ignored = TRUE))
## these better all end in "-RENAME"
setdiff(unlist(s), f$name)
## should end in "-tracked-none"
setdiff(f$name, unlist(s))
class(s)
methods(class = "git_status")
str(unclass(s))

#' ### Return value of `git2r::status()`
#'
#' What I think `git2r::status()` returns
#'
#'  * List with components, potentially
#'     - `staged`
#'     - `unstaged`
#'     - `untracked`
#'     - `ignored`
#'  * Each of those components is a non-uniquely named list of individual paths.
#'  The only exception is a staged rename, which holds a length 2 character
#'  vector.
#'  * `staged` can have components with name
#'     - `new`
#'     - `deleted`
#'     - `modified`
#'     - `renamed` <-- length 2 character vector, giving 'from' and 'to'
#'  * `unstaged` can have components with name
#'     - `deleted`
#'     - `modified`
#'  * `untracked` can have components with name
#'     - `untracked`
#'  * `ignored` can have components with name
#'     - `ignored`
#'  * A rename is only recognized as such if the deletion and addition are
#'  staged, i.e. there is no such thing as an unstaged rename.
#'
#' ### Actual `git_status()` output
#'

#' Skip to the present. Here's the current output of `git_status()`.
git_status(path, ls = TRUE)
