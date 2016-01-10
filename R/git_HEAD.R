#' Get HEAD for a repository
#'
#' Convenience wrapper around \code{\link[git2r]{head-methods}} from
#' \code{\link{git2r}}.
#'
#' @template repo
#'
#' @return A list with components:
#' \describe{
#'   \item{\code{branch_name}}{the name and ...}
#'   \item{\code{branch_type}}{type of the branch whose tip HEAD currently
#'   points to}
#'   \item{\code{head_sha}}{the SHA and ...}
#'   \item{\code{head_commit}}{\code{\linkS4class{git_commit}} object for the
#'   specific commit HEAD points to}
#'   \item{\code{repo}}{associated \code{\linkS4class{git_repository}} object}
#'   \item{\code{git_branch}}{associated \code{\linkS4class{git_branch}} object}
#' }
#'
#' @export
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' git_HEAD(repo = repo)
git_HEAD <- function(repo = ".") {
  gr <- as_git_repository(as.rpath(repo))
  h <- git2r::head(gr)
  if (is.null(h))
    return(h)
  hl <- dplyr::lst_(list(
    branch_name = ~ h@name,
    branch_type = ~ c("local", "remote")[h@type],
    head_sha = ~ git2r::branch_target(h),
    head_commit = ~ git2r::lookup(repo = gr, sha = head_sha),
    repo = ~ h@repo,
    git_branch = ~ h
    )
  )

  structure(hl, class = c("git_HEAD", "list"))
}

#' @export
print.git_HEAD <- function(x, ...) {
  cat(sprintf("On branch %s.\nMost recent commit:\n", x$branch_name))
  print(x$head_commit)
}
