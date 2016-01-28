is_in_repo <- function(x, ...) !is.null(as.rpath(x, ..., raise = NULL))

is_a_repo <- function(x) is_in_repo(x, ceiling = 0)

wd_is_clean <- function(repo = ".") {
  suppressMessages(
    s <- git_status(repo = repo)
  )
  length(unlist(s)) < 1
}

wd_is_dirty <- function(repo = ".") !wd_is_clean(repo = repo)
