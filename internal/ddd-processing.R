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

#' I have some rather useful functions for processing very diverse `...` input
#' to `git_config()` but damn if I remember how they work. And I may need this
#' stuff again for `git_add()`.
#'
#' ### `renquote()`
#'
#' Here it is and apparently I was inspired by [a question from Jeroen on
#' stackoverflow](http://stackoverflow.com/questions/19734412/flatten-nested-list-into-1-deep-list).

renquote <- function(l) {
  if (is.list(l)) {
    lapply(l, renquote) }
  else if (length(l) > 1) {
    lapply(as.list(l), renquote)
  } else {
    enquote(l)
  }
}

x <- list(foo = TRUE, bar = 456, baz = NULL,
          pets = list(cat = "meeuw", dog = "woof"),
          letters = c(a = "a", b = "b", c = "c"))
renquote(x)

#' This appears to recurse through the input list and apply `enquote()` to each
#' atom, by which I mean a list or vector element that is itself neither a list
#' nor a vector of length greater than 1. `enquote()` is described as "a simple
#' one-line utility which transforms a call of the form `Foo(....)` into the
#' call `quote(Foo(....))`. This is typically used to protect a call from early
#' evaluation."
#'
#' ### `list_depth_one()`
#'
#' I then use `renquote()` inside another function, `list_depth_one()`, like so:
list_depth_one <- function(x) lapply(unlist(renquote(x)), eval)

#' So here we go
list_depth_one(x)

#' And why wasn't I content with `unlist()`?
unlist(x)

#' The `NULL` is dropped and you get a vector, not a list, back. Both of which
#' matter for `git_config()`. I also note that everything gets coerced to
#' character, which doesn't happen to be a problem for `git_config()` but is
#' still a big difference.
#'
#' I think `unlist()` might actually get the job done in `git_add()`.
