#' List, create, checkout, or delete branches
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
#'   \code{\link[git2r]{branches}} function of \code{\link{git2r}} and,
#'   optionally, commit information for the current branch tips from
#'   \code{\link{git_log}}.
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
#' Returns a data frame (or tbl_df) with one row per branch. Default variables
#' are branch \code{name}, \code{type} (local vs remote), and a list-column of
#' \code{\linkS4class{git_branch}} objects. If \code{tips = TRUE}, additional
#' variables from \code{\link{git_log}} are returned, describing the the commit
#' each branch points to at the time of the call.
#'
#' @param which Which branches to list: \code{all} (the default), \code{local}
#'   only, or \code{remote} only.
#' @param tips Logical. Adds information from \code{\link{git_log}} on the
#'   commit currently at the tip of each branch. Defalts to \code{FALSE}.
#'
#' @export
#' @rdname githug-branches
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#'
#' ## no commits --> no branches
#' git_branch_list()
#'
#' ## commit and ... now we have master
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_COMMIT('1: not in the middle of nowhere')
#' git_branch_list()
#' git_branch_list(tips = TRUE)
#'
#' ## create new branch that points at HEAD
#' git_branch_create("earlybranch")
#' git_branch_list()
#'
#' ## another commit
#' write("but we can see it from here.", "nowhere.txt", append = TRUE)
#' git_COMMIT('2: but we can see it from here')
#'
#' ## create new branch that points at *first commit*, not HEAD
#' (gl <- git_log())
#' git_branch_create("hindsight", commit  = gl$commit[[2]])
#' git_branch_list()
#' git_branch_list(tips = TRUE)
#'
#' \dontrun{
#' ## try to re-create an existing branch and fail
#' git_branch_create("hindsight")
#' }
#'
#' ## try try again ... and use the force = TRUE
#' git_branch_create("hindsight", force = TRUE)
#' git_branch_list(tips = TRUE)
#'
#' ## checkout an existing branch
#' git_checkout("earlybranch")
#' git_branch()
#' git_HEAD()
#'
#' ## checkout master
#' git_checkout()
#' git_HEAD()
#'
#' ## checkout AND CREATE all at once
#' git_CHECKOUT("IMMEDIATE-GRATIFICATION")
#' git_HEAD()
#'
#' ## delete a branch
#' git_branch_delete("earlybranch")
#' git_branch_list()
#'
#' setwd(owd)
git_branch_list <- function(
  which = c("all", "local", "remote"), repo = ".", tips = FALSE) {

  gr <- as_git_repository(as.rpath(repo))
  which <- match.arg(which)

  gb <- git2r::branches(repo = gr, flags = which)
  if (is.null(gb) || length(gb) < 1) {
    message("No branches to list.")
    return(invisible(NULL))
  }

  ## TO DO? submit PR w/ proper coerce method to git2r, like the one to coerce
  ## git_repository objects to data.frame and then use that here
  gbl <- dplyr::data_frame(
    name = purrr::map_chr(gb, slot, "name"),
    type = c("local", "remote")[purrr::map_int(gb, slot, "type")],
    git_branch = gb
  )

  if (!tips) {
    return(gbl)
  }

  gbl <-
    dplyr::mutate_(gbl,
                   sha = ~ purrr::map_chr(gbl$git_branch, git2r::branch_target))
  glog <- git_log(repo = repo)
  vars <- c("name", "type", "sha", "message", "when", "author", "email",
            "summary", "commit", "git_branch")
  gbl <- gbl %>%
    dplyr::left_join(glog) %>%
    dplyr::select_(.dots = vars)
  ## apply git_log class for printing purposes
  structure(gbl, class = c("git_log", class(gbl)))

}

#' @section git_branch:
#'
#'   \code{git_branch} tells which branch you're on.
#'
#' @export
#' @rdname githug-branches
git_branch <- function(repo = ".") {
  gr <- as_git_repository(as.rpath(repo))
  git_HEAD(repo = repo)$branch_name
}

#' @section git_branch_create:
#'
#'   \code{git_branch_create} creates a new local branch. You must specify the
#'   \code{name} of the new branch, at the very least. By default, will try to
#'   determine \code{repo} from current working directory, get current HEAD from
#'   that, and point the new branch there. Optionally, you can provide the path
#'   to a \code{repo} and, via \code{...}, even other arguments to
#'   \code{\link[git2r]{branch_create}}: an arbitrary
#'   \code{\linkS4class{git_commit}} object to use as the branch's starting
#'   point or \code{force = TRUE} to overwrite an existing branch.
#'
#' @export
#' @rdname githug-branches
git_branch_create <- function(name, repo = ".", ...) {

  stopifnot(inherits(name, "character"), length(name) == 1L)

  ddd <- list(...)
  if (is.null(ddd$commit)) {
    h <- git_HEAD(repo = repo)
    ddd$commit <- h$head_commit
    msg_fodder <- capture.output(h$git_branch)
  } else {
    msg_fodder <- capture.output(ddd$commit)
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

#' @section git_branch_delete:
#'
#'   \code{git_branch_delete} deletes an existing local branch. Specify the
#'   branch by \code{name}. This wraps \code{\link[git2r]{branch_delete}} from
#'   \code{\link{git2r}}.
#'
#' @export
#' @rdname githug-branches
git_branch_delete <- function(name, repo = ".", ...) {
  stopifnot(inherits(name, "character"), length(name) == 1L)
  gbl <- git_branch_list(which = "local", repo = repo)
  gb <- gbl$git_branch[[name]]
  if (is.null(gb)) {
    msg <- "'%s' does not match any of the known local branches:\n%s"
    bl <- paste(gbl$name[gbl$type == "local"], collapse = "\n")
    stop(sprintf(msg, name, bl), call. = FALSE)
  }
  git2r::branch_delete(gb)
  message("Deleted branch '", name, "'")
  invisible(NULL)
}

#' @section git_checkout:
#'
#'   \code{git_checkout} checks out an existing local branch. Specify the branch
#'   by \code{name} or checkout \code{master} by default. This wraps
#'   \code{\link{git2r}}'s \code{\link[git2r]{checkout,git_branch-method}}.
#'
#' @export
#' @rdname githug-branches
git_checkout <- function(name = "master", repo = ".", ...) {
  stopifnot(inherits(name, "character"), length(name) == 1L)
  gbl <- git_branch_list(which = "local", repo = repo)
  gb <- gbl$git_branch[[name]]
  if (is.null(gb)) {
    msg <- "'%s' does not match any of the known local branches:\n%s"
    bl <- paste(gbl$name[gbl$type == "local"], collapse = "\n")
    stop(sprintf(msg, name, bl), call. = FALSE)
  }
  git2r::checkout(object = gb, ...)
  ghead <- git_HEAD(repo = repo)
  message("Switched to branch '", ghead$branch_name, "'")
  invisible(ghead$branch_name)
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
  ghead <- git_HEAD(repo = repo)
  message("Switched to branch '", ghead$branch_name, "'")
  invisible(ghead$branch_name)

}

