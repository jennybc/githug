#' Report current or list all branches
#'
#' Report which branch you're currently on or list all local and/or remote
#' branches in the repository.
#'
#' @template repo
#'
#' @name githug-branch
#' @aliases git_branch git_branch_list git_branch_current
NULL

#' @section git_branch:
#'
#'   If called with no arguments, or with only the \code{repo} argument,
#'   \code{git_branch()} reports the name of the current branch. This is
#'   equivalent to calling \code{git_branch_current()} directly.
#'
#'   If the \code{where} argument is given, its value is passed through to
#'   \code{git_branch_list()}.
#'
#' @export
#' @rdname githug-branch
#' @examples
#' repo <- git_init(tempfile("githug-branches-"))
#' owd <- setwd(repo)
#'
#' ## no commits --> no branches
#' git_branch()
#' git_branch_list()
#'
#' ## commit and ... now we have master
#' writeLines("Well, we're not in the middle of nowhere...", "nowhere.txt")
#' git_commit(all = TRUE, message = "1ouise: not in the middle of nowhere")
#' git_branch()
#' git_branch_list()
#'
#' setwd(owd)
git_branch <- function(where = NULL, repo = ".") {
  if (is.null(where)) {
    return(git_branch_current(repo = repo))
  }
  git_branch_list(where = where, repo = repo)
}

#' @section git_branch:
#'
#'   \code{git_branch()} tells which branch you're currently on.
#'
#' @export
#' @rdname githug-branch
git_branch_current <- function(repo = ".") {
  gr <- as.git_repository(repo)
  h <- git2r::head(gr)
  if (is.null(h)) {
    message("Not on a branch.")
    return(invisible(h))
  }
  h@name
}

#' @section git_branch_list:
#'
#'   \code{git_branch_list()} returns a data frame of information provided by
#'   \code{\link[git2r:branches]{git2r::branches}()}.
#'
#' How it corresponds to command line Git:
#'
#' \describe{
#'   \item{\code{git_branch_list()}}{is like \code{git branch}. Lists local
#'   branches.}
#'   \item{\code{git_branch_list(where = "all")}}{is like \code{git branch -a}.
#'   Lists all branches, local and remote.}
#'   \item{\code{git_branch_list(where = "remote")}}{is like \code{git branch
#'   -r}. Lists remote branches.}
#' }
#'
#' @param where Which branches to list: \code{local} only (the default),
#'   \code{all}, or \code{remote} only.
#' @export
#' @rdname githug-branch
git_branch_list <- function(where = c("local", "all", "remote"), repo = ".") {
  gr <- as.git_repository(repo)
  where <- match.arg(where)

  gb <- git2r::branches(repo = gr, flags = where)
  if (length(gb) < 1) {
    message("No branches to list.")
    return(invisible())
  }

  gbl <- parse_branches(purrr::map_chr(gb, methods::slot, "name"))
  gbl$type <- c("local", "remote")[purrr::map_int(gb, methods::slot, "type")]
  gbl$gb <- gb
  gbl$HEAD <- purrr::map_lgl(gb, git2r::is_head)

  vars <- c("HEAD", "full_name", "type", "branch", "remote", "gb")
  gbl[vars]

  ## TO DO: revisit once I've dealt with remotes and could somehow indicate
  ## branch tracking relationships

  ## TO PONDER: should info about HEAD only appear in printed object but not in
  ## object itself? Because it's more perishable than all the other info.

  ## TO ADD? previous version had the option to add the commit at the tip of
  ## each branch but I can't really remember why/if that was important
  ## implement like so:
  ## purrr::map_chr(gb, git2r::branch_target) --> SHAs
  ## add them to gbl
  ## probably skip this step given current design: left_join to git_history()
  ## by SHA
  ## I think the point of that was to pick up the git_commit objects?
  ## select (reorder) variables
  ## maybe: apply git_history class for printing purposes
  ## (would require work there)
  ##
  ## after some usage, I now think it would be nice to display some info about
  ## the tip commit for each branch
}

parse_branches <- function(x) {
  m <- regexpr("((?P<remote>.*)/)?(?P<branch>.*)", x, perl = TRUE)
  capt_start <- attr(m, "capture.start")
  capt_len <- attr(m, "capture.length")
  res <- vapply(
    c("branch", "remote"),
    function(wh) {
      ## list is necessary because "simplification is always done in vapply"
      ## otherwise res drops from dim 2 --> 1 when there's only 1 branch
      list(substring(x, capt_start[ , wh],
                     capt_start[ , wh] + capt_len[ , wh] - 1))
    },
    list("foo")
  )
  res <- tibble::tibble(
    full_name = x,
    branch = res[["branch"]],
    remote = res[["remote"]]
  )
  res$remote[res$remote == ""] <- NA_character_
  res
}

## input: branch name
## output git_branch object
git_branch_from_name <- function(name, repo) {
  gbl <- git_branch_list(where = "local", repo = repo)
  gbl$gb[[name]]
}
