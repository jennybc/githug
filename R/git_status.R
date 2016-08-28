#' Get status of a Git repo
#'
#' The status of a Git repo is a set of paths, typically broken down like so:
#' \describe{
#' \item{Staged changes}{Paths with modifications that are staged for inclusion
#' in the next commit.}
#' \item{Unstaged changes}{Paths that are tracked by Git but that have unstaged
#' modifications.}
#' \item{Untracked files}{Paths that are not yet tracked by Git but that are
#' also not gitignored.}
#' }
#' What does that leave? Two kinds of paths
#' \itemize{
#' \item Unchanged, tracked files.
#' \item Ignored files.
#' }
#' Use \code{ls = TRUE} to request a status that includes these paths as well,
#' i.e. a complete census of all the files in the repo.
#'
#' @param ls Logical, indicating whether to include unchanged, tracked files
#'   and gitignored files. Default is \code{FALSE}.
#' @template repo
#'
#' @return a data frame where each row describes changes to a path, invisibly
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Add me", "add-me")
#' write("Don't add me", "dont-add-me")
#' git_status()
#' git_add("add-me")
#' git_status()
#' git_commit(message = "first commit")
#' git_status()
#' git_status(ls = TRUE)
#' setwd(owd)
git_status <- function(repo = ".", ls = FALSE) {
  gbn <- git_branch(repo = repo)
  if (!is.null(gbn)) {
    ## this is cat(), not message(), to help auto-generate safety commit messages
    cat("On branch:\n  *", gbn, "\n")
    ## TODO: maybe add sthg about last commit?
  }
  git_status_check(repo = repo, ls = ls)
}

git_status_check <- function(repo = ".", ls = FALSE) {

  stopifnot(is_lol(ls))

  ## convert from git2r's git_status object (a list)
  ## to a tibble (maybe a githug_status object + print method? shelving for now)
  s <- git2r::status(repo = as.git_repository(repo), staged = TRUE,
                     unstaged = TRUE, untracked = TRUE, ignored = ls)

  if (sum(lengths(s)) > 0) {

    stl <- purrr::map(s, tibble::enframe, name = "change", value = "path")

    ## we need to explicitly sort somewhere and it's easiest right here
    ## i.e. before renames get expanded
    STATII <- c("staged", "unstaged", "untracked", "ignored") # + tracked
    CHANGES <- c("new", "modified", "renamed", "deleted",
                 "untracked", "ignored") # + none
    stl <- stl[order(match(names(stl), STATII))]
    sfun <- function(df) df[order(match(df$change, CHANGES)), ]
    stl <- purrr::map(stl, sfun)

    ## add index i to link paths associated with a rename
    ## set column order
    ifun <- function(df) {
      is_a_rename <- lengths(df$path) > 1
      df$i <- rep(NA_integer_, nrow(df))
      df$i[is_a_rename] <- seq_len(sum(is_a_rename))
      df[c("path", "change", "i")]
    }
    stl <- purrr::map(stl, ifun)

    ## unnest/flatten the path list-column
    jfun <- function(df) purrr::pmap_df(df, tibble::tibble)
    ## rowbind the status-specific tibbles + prepend status variable as .id
    st <- purrr::map_df(stl, jfun, .id = "status")
  } else {
    st <- tibble::tibble(
      status = character(),
      path = character(),
      change = character(),
      i = integer()
    )
  }

  renamed <- st$change == "renamed"
  st$change[renamed] <- paste(st$change[renamed], c("from", "to"), sep = "_")

  ## get tracked but unchanged paths, a la git ls-files
  if (ls) {
    tracked <- setdiff(dir(repo), st$path)
    nt <- length(tracked)
    if (nt > 0) {
      ## use tibble::add_row() if gets fixed
      ## https://github.com/hadley/tibble/pull/142
      ## this seems crazy but what else to do w/o rbind for tibbles?
      st <- tibble::tibble(
        status = c(st$status, rep.int("tracked", nt)),
        path =   c(st$path,   tracked),
        change = c(st$change, rep.int("none", nt)),
        i = c(st$i, rep.int(NA_integer_, nt))
      )
    }
  }
  ## TO WORRY: this just seems misleading / weird
  st$change[st$change %in% c("untracked", "ignored")] <- "new"

  st

}
