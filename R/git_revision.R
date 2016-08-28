#' Identify commits like a human
#'
#' Retrieve the SHA-1 for a specific commit via a human-friendly description,
#' like
#' \itemize{
#' \item \code{HEAD}: the most recent commit and the one that will be
#' parent to the next commit.
#' \item \code{master@{1 month ago}}: the tip commit of the
#' \code{master} branch this time last month
#' \item \code{bug-fix}: the tip commit of the \code{bug-fix} branch
#' \item \code{feature^}: parent of the tip commit of the \code{feature} branch
#' \item \code{master~2}: grandparent of the tip commit of the \code{master}
#' branch
#' \item \code{8675309}: commit with \code{8675309} as leading substring of SHA-1
#' }
#' Convenience wrapper around
#' \code{\link[git2r:revparse_single]{git2r::revparse_single}()}, which
#' implements functionality from \code{git rev-parse}.
#'
#' @template rev
#' @template repo
#' @template return-SHA-with-hint
#'
#' @references
#'
#' \href{https://git-scm.com/book/en/v2/Git-Tools-Revision-Selection}{Revision
#' Selection} from the Pro Git book by Scott Chacon and Ben Straub
#'
#' Specifying revisions section of the
#' \href{https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions}{git-rev-parse
#' man page}
#'
#' @name git-revision
#' @aliases git_revision git_revision_exists
#' @examples
#' repo <- git_init(tempfile("githug-revisions-"))
#' owd <- setwd(repo)
#'
#' ## no commits --> HEAD cannot be resolved
#' git_revision_exists("HEAD")
#' \dontrun{
#' git_revision()
#' }
#'
#' ## commit and ... now HEAD exists
#' write("Well, we're not in the middle of nowhere,", "nowhere.txt")
#' git_commit(all = TRUE, message = "1ouise: not in the middle of nowhere")
#' git_revision()
#' git_revision_exists("HEAD")
#'
#' ## make a new commit then ask for parent of HEAD
#' write("but we can see it from here.", "nowhere.txt", append = TRUE)
#' git_commit(all = TRUE, message = "louise: but can see it")
#' git_revision("HEAD^")
#'
#' ## create a new branch and find out what it points at
#' git_switch("newbranch", create = TRUE)
#' git_revision("newbranch")
#'
#' setwd(owd)
NULL

#' @section git_revision:
#'
#'   If called with no arguments, this returns SHA for HEAD of repo associated
#'   with current working directory.
#'
#' @export
#' @rdname git-revision
git_revision <- function(rev = "HEAD", repo = ".") {
  git_revision_sha(rev = rev, repo = repo)
}

#' @section git_revision_exists:
#'
#'   Tests if \code{rev} can be resolved to a specific commit.
#'
#' @export
#' @rdname git-revision
git_revision_exists <- function(rev, repo = ".") {
  git_revision_inherits(rev = rev, is = "git_commit", repo = repo)
}

git_revision_inherits <- function(rev, is = NULL, repo = ".") {
  x <- git_revision_resolve(rev = rev, repo = repo)
  !inherits(x, "try-error") && (is.null(is) || inherits(x, is))
}

## only differs from exported version in the flexibility to enhance the stop
## message; meant for internal use
git_revision_sha <- function(rev, repo = ".", desc = NULL) {
  gco <- git_revision_gco(rev = rev, repo = repo, desc = desc)
  sha_with_hint(gco)
}

## will error if rev does not resolve SPECIFICALLY to a git_commit
git_revision_gco <- function(rev = "HEAD", repo = ".", desc = NULL) {
  gco <- git_revision_resolve(rev = rev, repo = repo)
  if (inherits(gco, "try-error")) {
    desc <- desc %||% paste0("the revision '", rev, "'")
    msg <- paste0("Can't find ", desc, " in this repo:\n", repo_path(repo))
    stop(msg, call. = FALSE)
  }
  if (!git2r::is_commit(gco)) {
    ## if I'm getting a git_tag or git_branch here, it is not intentional!
    stop("rev '", rev, "' resolves to a ", class(gco),
         ", not a git_commit", call. = FALSE)
  }
  gco
}

## goal here is to catch error when rev cannot be found
## and return to other functions, who can decide what to do about that
git_revision_resolve <- function(rev = "HEAD", repo = ".") {
  stopifnot(is.character(rev), length(rev) == 1)
  try(git2r::revparse_single(as.git_repository(repo), rev), silent = TRUE)
}

## stopifnot but for revisions and w/ a message in English
stop_if_no_rev <- function(rev, repo = ".",
                           desc = paste0("the revision '", rev, "'")) {
  if (git_revision_exists(rev = rev, repo = repo)) {
    return(invisible())
  }
  msg <- paste0("Can't find ", desc, " in this repo:\n", repo_path(repo))
  stop(msg, call. = FALSE)
}

## constructor for specific bits of the extended SHA-1 syntax
## https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions
## usage:
## git_revision_spell(text = "thelma")        --> HEAD^{/thelma}
## git_revision_spell(rev = "1234567", n = 5) --> 1234567^^^^^
git_revision_spell <- function(rev = "HEAD", n = 0, text = character()) {
  if (length(text) == 0L) {
    return(paste0(rev, strrep("^", n)))
  }
  paste0(rev, "^{/", text, "}")
}
