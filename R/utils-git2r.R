## can I resolve a revision?
## optionally: is it of a particular class?
rev_exists <- function(rev, is = NULL, repo = ".") {
  x <- git_rev_resolve(rev = rev, repo = repo)
  !inherits(x, "try-error") && (is.null(is) || inherits(x, is))
}

## stopifnot but for revisions and w/ a message in English
stop_if_no_rev <- function(rev, repo = ".", desc = NULL) {
  if (rev_exists(rev = rev, repo = repo)) {
    return(invisible())
  }
  desc <- desc %||% paste0("the revision '", rev, "'")
  msg <- paste0("Can't find ", desc, " in this repo:\n", repo_path(repo))
  stop(msg, call. = FALSE)
}

## primary input = revision string
## output = S4 git_commit object
## will error if rev does not resolve SPECIFICALLY to a git_commit
git_rev_gco <- function(rev = "HEAD", repo = ".", stop = NULL) {
  gco <- git_rev_resolve(rev = rev, repo = repo)
  if (inherits(gco, "try-error")) {
    stop(stop %||% attr(gco, "condition"), call. = FALSE)
  }
  if (!git2r::is_commit(gco)) {
    ## I have no immediate plans to intentionally retrieve a git_tag or
    ## git_tree with this function
    stop("rev '", rev, "' resolves to a ", class(gco),
         ", not a git_commit", call. = FALSE)
  }
  gco
}

## primary input = revision string
## output = SHA-1
git_rev_sha <- function(rev = "HEAD", repo = ".", stop = NULL) {
  gco <- git_rev_gco(rev = rev, repo = repo, stop = stop)
  sha_with_hint(gco)
}

## goal here is to catch error when rev cannot be found
## and return to other functions, who can decide what to do about that
git_rev_resolve <- function(rev = "HEAD", repo = ".") {
  stopifnot(is.character(rev), length(rev) == 1)
  try(git2r::revparse_single(as.git_repository(repo), rev), silent = TRUE)
}

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

## https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions
## usage:
## git_rev_gco(rev_spell(text = "thelma"))
## git_rev_gco(rev_spell(rev = "1234567", n = 2))
rev_spell <- function(rev = "HEAD", n = 0, text = character()) {
  if (length(text) == 0L) {
    return(paste0(rev, strrep("^", n)))
  }
  paste0(rev, "^{/", text, "}")
}
