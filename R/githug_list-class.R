#' @export
print.githug_list <- function(x, ...) {
  print(jsonlite::toJSON(unclass(x), pretty = TRUE, auto_unbox = TRUE))
  invisible(x)
}

#' @export
`[.githug_list` <- function(x, i) {
  structure(.subset(x, i), class = c("githug_list", "list"))
}
