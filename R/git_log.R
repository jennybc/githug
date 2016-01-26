#' Get a commit log
#'
#' Get a commit log. Convenience wrapper around the \code{\link{git2r}}
#' functions \code{\link[git2r]{coerce-git_repository-method}}, which coerces
#' the commit log of the repository to a data frame, and
#' \code{\link[git2r]{commits}}, which returns individual
#' \code{\linkS4class{git_commit}} objects. The print method shows truncated
#' versions of selected variables, e.g., the commit message, time, and SHA, but
#' rest assured the full information is present in the returned object.
#'
#' @template repo
#' @return A data frame (or tbl_df) with S3 class \code{git_log}, solely for
#'   printing purposes. Variables: the commit \code{message}, \code{when} the
#'   commit happened, \code{author}, \code{SHA}, \code{email}, \code{summary},
#'   and a list-column of objects of class \code{\linkS4class{git_commit}}.
#' @export
#' @examples
#' require(dplyr, quietly = TRUE)
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' line1 <- "Thelma: You're a real live outlaw, aren't ya?"
#' line2 <- paste("J.D.: Well I may be an outlaw, darlin', but you're the one",
#'                "stealing my heart.")
#' writeLines(line1, "tl.txt")
#' git_COMMIT(line1)
#' write(line2, "tl.txt", append = TRUE)
#' git_COMMIT(line2)
#' git_log()
#' setwd(owd)
git_log <- function(repo = ".") {

  repo <- as.rpath(repo, raise = warning)

  if (is.null(repo)) {

    gr <- NULL

  } else {

    gr <- as_git_repository(repo)

    commits <- git2r::commits(gr)
    commits <- dplyr::data_frame(sha = purrr::map_chr(commits, slot, "sha"),
                                 commit = commits)

    gr <- as(gr, "data.frame")
    if (is.null(gr)) gr <- dplyr::data_frame(sha = character())
    gr <- dplyr::tbl_df(gr)

    ## using match because row order must absolutely be retained
    gr <- gr %>%
      dplyr::mutate(commit = commits$commit[match(gr$sha, commits$sha)])

  }

  if (is.null(gr) || nrow(gr) < 1) {
    message("no commits yet")
    return(invisible(NULL))
  }

  vars <- c("message", "when", "author", "sha", "email", "summary", "commit")
  structure(dplyr::select_(gr, .dots = vars), class = c("git_log", class(gr)))
}

#' @export
print.git_log <- function(x, ...) {
  x %>%
    dplyr::mutate_(message = ~ ellipsize(message, 24),
                   when = ~ format(when, "%Y-%m-%d %H:%M"),
                   sha = ~ ellipsize(sha, 7, ellipsis = ''),
                   summary = ~ ellipsize(summary, 24)) %>%
    print()
}
