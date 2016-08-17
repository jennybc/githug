is_lol <- function(x) is.logical(x) && length(x) == 1L

dir_exists <- function(x) {
  stopifnot(is.character(x), length(x) == 1L)
  utils::file_test("-d", x)
}

file_exists <- function(x) {
  stopifnot(is.character(x), length(x) == 1L)
  utils::file_test("-f", x)
}

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

screen <- function(x, y) if (length(y)) stats::setNames(x[y], y) else x

list_to_chr <- function(x) vapply(x, `[`, character(1))

is_named <- function(x) {
  nms <- names(x)
  !is.null(nms) &&
    all(!is.na(nms)) &&
    all(nzchar(nms))
}

`%||%` <- function(x, y) if (is.null(x)) y else x

## walk up parent dirs until you find one that exists
least_existing_dir <- function(path) {
  stopifnot(length(path) == 1L, is.character(path), path != "")
  path <- normalize_path(path)
  #cat(path, "\n")
  if (dir.exists(path))
    return(path)
  else
    least_existing_dir(dirname(path))
}

normalize_path <- function(path) {
  normalizePath(path, winslash = "/", mustWork = FALSE)
}

normalize_path_strict <- function(path) {
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

message_nl <- function(...) message(paste(..., collapse = "\n"))

yesno <- function(...) {
  cat(paste0(..., collapse = ""))
  utils::menu(c("yes", "no")) == 1
}

get_user_input <- function(...) {
  messages <- as.character(unlist(list(...)))
  lapply(utils::head(messages, -1), message)
  trimws(readline(paste0(messages[length(messages)], ": ")))
}

ellipsize <- function(x, n = 20, ellipsis = "\u2026") {
  ifelse(nchar(x) > n,
         paste0(substr(x, start = 1, stop = n - nchar(ellipsis)), ellipsis),
         x)
}

midlipsize <- function(x, n = 20, ellipsis = "\u2026") {
  if (length(x) == 0L || nchar(x) <= n) return(x)
  half <- (n - nchar(ellipsis))/2
  paste0(substr(x, start = 1, stop = ceiling(half)),
         ellipsis,
         substr(x, start = nchar(x) - floor(half) + 1, stop = nchar(x)))
}

bulletize_git_commit <- function(gco) {
  stopifnot(git2r::is_commit(gco))
  posix_when <- methods::as(gco@author@when, "POSIXct")
  sprintf("  * [%s] %s: %s",
          substr(gco@sha, 1, 7),
          format(posix_when, format = "%Y-%m-%d"),
          ellipsize(gco@message, 55))
}

sha_with_hint <- function(gco) {
  stopifnot(git2r::is_commit(gco))
  posix_when <- methods::as(gco@author@when, "POSIXct")
  structure(gco@sha,
            hint = paste(format(posix_when, format = "%Y-%m-%d %H:%M"),
                         ellipsize(gco@message, 45)))
}
