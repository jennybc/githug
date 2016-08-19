git_HEAD <- function(repo = ".", stop = NULL) {
  git_rev_resolve(rev = "HEAD", repo = repo, stop = stop)
}

git_rev_resolve <- function(rev = "HEAD", repo = ".", stop = NULL) {
  stopifnot(is.character(rev), length(rev) == 1)
  gco <- try(git2r::revparse_single(as.git_repository(repo), rev), silent = TRUE)
  if (inherits(gco, "try-error")) {
    stop(stop %||% gco, call. = FALSE)
  }
  if (!git2r::is_commit(gco)) {
    ## I have no immediate plans to intentionally retrieve a git_tag or
    ## git_tree with this function
    stop("rev '", rev, "' resolves to a ", class(gco),
         ", not a git_commit", call. = FALSE)
  }
  gco
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
