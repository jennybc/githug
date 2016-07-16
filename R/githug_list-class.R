#' @export
print.githug_list <- function(x, ...) {
  lapply(names(x), function(nm) cat(sprintf("%s = %s\n", nm, x[[nm]])))
  invisible(x)
}

#' @export
`[.githug_list` <- function(x, i) {
  structure(.subset(x, i), class = c("githug_list", "list"))
}
