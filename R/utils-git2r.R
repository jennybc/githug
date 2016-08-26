git_HEAD <- function(repo = ".", stop = paste0(
  "Can't find the most recent commit (a.k.a. HEAD) in this repo:\n",
  git2r::workdir(as.git_repository(repo)))) {
  git_rev_gco(rev = "HEAD", repo = repo, stop = stop)
}

git_HEAD_parent <- function(repo = ".", stop = NULL) {
  ## https://github.com/jennybc/githug0/issues/32
  git_rev_gco(rev = "HEAD^", repo = repo, paste0(
    "Can't find the parent of the most recent commit\n",
    "  (a.k.a. HEAD^) in this repo:\n",
    git2r::workdir(as.git_repository(repo)),
    "\n\ngithug can't carry out the current operation\n",
    "  without this parent commit.\n",
    "One day githug will be able to workaround this,\n",
    "  But that is not this day :("
  ))
}

git_rev_gco <- function(rev = "HEAD", repo = ".", stop = NULL) {
  stopifnot(is.character(rev), length(rev) == 1)
  gr <- as.git_repository(repo)
  gco <- try(git2r::revparse_single(gr, rev), silent = TRUE)
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

git_rev_sha <- function(rev = "HEAD", repo = ".", stop = NULL) {
  gco <- git_rev_gco(rev = rev, repo = repo, stop = stop)
  sha_with_hint(gco)
}

sha_with_hint <- function(gco) {
  stopifnot(git2r::is_commit(gco))
  structure(gco@sha,
            when = methods::as(gco@author@when, "POSIXct"),
            msg_start = substr(gco@message, 1, 72))
}

bulletize_sha <- function(sha, format = "%Y-%m-%d") {
  sprintf("  * [%s] %s: %s",
          substr(sha, 1, 7),
          format(attr(sha, "when"), format = format),
          ellipsize(attr(sha, "msg_start"), 55))
}

bulletize_git_commit <- function(gco, format = "%Y-%m-%d") {
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

