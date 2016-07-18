#' @export
print.githug_list <- function(x, ...) {
  ## NULLs need to be preserved because conveys variable did not exist
  ## necessary for roundtrips
  ## therefore NULLs also need to be printed
  xp <- vapply(x, `%||%`, character(1), y = "NULL")
  lapply(names(xp), function(nm) cat(sprintf("%s = %s\n", nm, xp[[nm]])))
  invisible(x)
}

#' @export
`[.githug_list` <- function(x, i) {
  structure(.subset(x, i), class = c("githug_list", "list"))
}
