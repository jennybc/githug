#' Address a commit, the git2r way
#'
#' Use this to convert a
#' \href{https://git-scm.com/docs/git-rev-parse.html#_specifying_revisions}{revision
#' string} into an object of class \code{\linkS4class{git_commit}}, which is how
#' the \code{\link{git2r}} package handles Git commits.
#'
#' \code{githug} uses \code{\link{git2r}}, under the hood, to perform local Git
#' operations. While \code{githug} always identifies a commit via its SHA or a
#' revision string, \code{\link{git2r}} handles repositories as objects of class
#' \code{\linkS4class{git_commit}}. If you want to do a Git operation that isn't
#' exposed via \code{githug}, this function helps you specify the commit
#' \code{\link{git2r}}-style.
#'
#' @param x Target commit, as a
#'   \href{http://git-scm.com/docs/git-rev-parse.html#_specifying_revisions}{revision
#'    string}, e.g. \code{HEAD^}, \code{branchname}, \code{SHA-1} or a leading
#'   substring thereof.
#' @template repo
#' @param ... additional arguments (none currently in use)
#'
#' @return An S4 \code{\linkS4class{git_commit}} object
#'
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' write("You get what you settle for.", "louise.txt")
#' git_commit(all = TRUE,
#'            message = "Brains'll only get you so far and luck always runs out.")
#' write("If done properly armed robbery doesn't have to be a totally unpleasant experience.",
#'       "jd.txt")
#' git_commit("jd.txt", message = "J.D. is charming")
#'
#' ## refer to these commits
#' as.git_commit("HEAD")
#' as.git_commit("HEAD^")
#' as.git_commit("master~1")
#'
#' setwd(owd)
#' @export
as.git_commit <- function(x, repo = ".", ...) UseMethod("as.git_commit")

#' @export
as.git_commit.character <- function(x = "HEAD", repo = ".", ...) {
  git_revision_gco(x, repo = repo)
}
