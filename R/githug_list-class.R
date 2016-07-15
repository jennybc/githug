#' Print a list JSON-style
#'
#' @param x The list to print.
#' @param ... Ignored.
#' @return The input \code{x} is passed through invisibly.
#' @export
print.githug_list <- function(x, ...) {
  print(jsonlite::toJSON(unclass(x), pretty = TRUE, auto_unbox = TRUE))
  invisible(x)
}

#' @export
`[.githug_list` <- function(x, i) {
  structure(.subset(x, i), class = c("githug_list", "list"))
}

## so far, I'm only using this on git config output and there's no real need for
## this, i.e. the lists in question are not recursive
#' #' @export
#' `[[.githug_list` <- function(x, i) {
#'   structure(.subset2(x, i), class = c("githug_list", "list"))
#' }
