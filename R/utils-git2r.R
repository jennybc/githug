## input = an S4 git_commit object
## output = SHA-1 as length 1 character, w/ other info as attributes
sha_with_hint <- function(gco) {
  stopifnot(git2r::is_commit(gco))
  structure(gco@sha,
            when = methods::as(gco@author@when, "POSIXct"),
            msg_start = substr(gco@message, 1, 72))
}

## input = SHA-1
## output = string suitable for bullet-list reporting
bulletize_sha <- function(sha, format = "%Y-%m-%d") {
  stopifnot(is.character(sha))
  sprintf("  * [%s] %s: %s",
          substr(sha, 1, 7),
          format(attr(sha, "when"), format = format),
          ellipsize(attr(sha, "msg_start"), 55))
}

## input = S4 git_commit object
## output = string suitable for bullet-list reporting
bulletize_gco <- function(gco, format = "%Y-%m-%d") {
  stopifnot(git2r::is_commit(gco))
  sha <- sha_with_hint(gco)
  bulletize_sha(sha, format = format)
}
