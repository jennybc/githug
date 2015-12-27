is_named <- function(x) {
  nms <- names(x)
  !is.null(nms) &&
    all(!is.na(nms)) &&
    all(nms != "")
}

list_to_chr <- function(x) vapply(x, `[`, character(1))

screen <- function(x, y) if (length(y)) setNames(x[y], y) else x

## inspired by
## http://stackoverflow.com/questions/19734412/flatten-nested-list-into-1-deep-list
renquote <- function(l) {
  if (is.list(l)) {
    lapply(l, renquote) }
  else if (length(l) > 1) {
    lapply(as.list(l), renquote)
  } else {
    enquote(l)
  }
}
## make into a depth one list but: preserve NULLs + names and atomize vectors
list_depth_one <- function(x) lapply(unlist(renquote(x)), eval)
