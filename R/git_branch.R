#' List, query, create, or checkout branches
#'
#' Convenience wrappers around branch-related functions from
#' \code{\link{git2r}}.
#'
#' @template repo
#' @param name Name of the branch.
#' @param ... Additional optional arguments to pass along to
#'   \code{\link{git2r}}.
#'
#' @name githug-branches
#' @aliases git_branch_list git_branch_create git_checkout git_CHECKOUT
NULL

#' @section git_branch_list:
#'
#'   \code{git_branch_list} returns a data frame of information provided by the
#'   \code{\link[git2r]{branches}} function of \code{\link{git2r}}.
#'
#' How it corresponds to command line Git:
#'
#' \describe{
#'   \item{\code{git_branch_list()}}{is like \code{git branch -a}. Lists all
#'   branches}
#'   \item{\code{git_branch_list("local")}}{is like \code{git branch}. Lists
#'   only local branches.}
#'   \item{\code{git_branch_list("remote")}}{is like \code{git branch -r}. Lists
#'   only remote branches.}
#' }
#'
#' Returns a data frame (or tbl_df) with one row per branch. Variables are
#' branch \code{name}, \code{type} (local vs remote), and a list-column of
#' \code{\linkS4class{git_branch}} objects.
#'
#' @param which Which branches to list: \code{all} (the default), \code{local}
#'   only, or \code{remote} only.
#'
#' @export
#' @rdname githug-branches
#' @examples
#' ## TO DO: come back when I can clone and truly show local v. remote
#' git_branch_list()
git_branch_list <- function(which = c("all", "local", "remote"), repo = ".") {

  gr <- as_git_repository(as.rpath(repo))
  which <- match.arg(which)
  gb <- git2r::branches(repo = gr, flags = which)
  ## TO DO? submit PR w/ proper coerce method to git2r, like the one to coerce
  ## git_repository objects to data.frame and then use that
  dplyr::data_frame(
    name = purrr::map_chr(gb, slot, "name"),
    type = c("local", "remote")[purrr::map_int(gb, slot, "type")],
    git_branch = gb
  )
}

#' @section git_branch_create:
#'
#'   \code{git_branch_create} creates a new local branch. You must specify the
#'   \code{name} of the new branch, at the very least. By default, will try
#'   determine \code{repo} from current working directory and then determine
#'   current HEAD from that. Optionally, you can provide the path to a
#'   \code{repo} and, via \code{...}, even other arguments to
#'   \code{\link[git2r]{branch_create}}, such as an arbitrary
#'   \code{\linkS4class{git_commit}} object to use as the branch's starting
#'   point.
#'
#' @return Branch name
#' @export
#' @rdname githug-branches
#' @examples
#' \dontrun{
#' ## TODO: come back! this just here to satisfy R CMD check
#' git_branch_create()
#' }
git_branch_create <- function(name, repo = ".", ...) {

  stopifnot(inherits(name, "character"), length(name) == 1L)

  ddd <- list(...)
  if (is.null(ddd$commit)) {
    h <- hug_HEAD(repo = repo)
    ddd$commit <- h$head_commit
    msg_fodder <- capture.output(h$git_branch)
  } else {
    ## TO DO: get the SHA or something here
    msg_fodder <- "basing on a commit"
  }

  if (is.null(ddd$commit)) {
    stop("Can't confirm a valid commit to use as base of new branch.\n",
         "Use git_log() to see previous commits.\n",
         "Maybe there aren't any?", call. = FALSE)
  }

  message("Basing new branch on:\n  ", msg_fodder)
  bc_args <- c(name = name, ddd)
  gb <- do.call(git2r::branch_create, bc_args)
  message("Creating branch ", gb@name)
  invisible(gb@name)

}

#' @section git_checkout:
#'
#'   \code{git_checkout} checks out an existing branch. You must specify the
#'   branch \code{name} at the very least. This wraps \code{\link{git2r}}'s
#'   \code{\link[git2r]{checkout,git_branch-method}}.
#'
#' @export
#' @rdname githug-branches
git_checkout <- function(name, repo = ".", ...) {
  stopifnot(inherits(name, "character"), length(name) == 1L)
  ## QUESTION: could the branch be remote?
  gbl <- git_branch_list(which = "local", repo = repo)
  gb <- gbl$git_branch[gbl$name == name]
  ## TO DO: make sure gb is reasonable
  git2r::checkout(object = gb, ...)
  ## get HEAD and return branch name? I have to return something and checkout
  ## returns NULL invisibly

}

#' @section git_CHECKOUT:
#'
#'   \code{git_CHECKOUT} checks out a branch AND creates it if necessary. This
#'   wraps \code{\link{git2r}}'s
#'   \code{\link[git2r]{checkout,git_repository-method}}.
#' @rdname githug-branches
#' @export
#' @rdname githug-branches
git_CHECKOUT <- function(name, repo = ".", ...) {
  stopifnot(inherits(name, "character"), length(name) == 1L)
  ## QUESTION: how much does it bother me that
  ## git_branch_create + git_checkout != git_CHECKOUT
  ## wrt messaging and checks?
  gr <- as_git_repository(as.rpath(repo))
  git2r::checkout(object = gr, branch = name, create = TRUE, ...)
  ## get HEAD and return branch name? I have to return something and checkout
  ## returns NULL invisibly

}
