#' Get the commit history
#'
#' Get an overview of the last \code{n} commits. Convenience wrapper around
#' \code{\link[git2r:commits]{git2r::commits}()}, which returns
#' \code{\linkS4class{git_commit}} objects, and the
#' \code{\link[git2r]{coerce-git_repository-method}}, which coerces the commit
#' log of the repository to a data frame. The print method shows truncated
#' versions of selected variables, e.g., the commit message, time, and SHA, but
#' rest assured the full information is present in the returned object.
#'
#' @param n Optional upper limit on the number of commits to output.
#' @template repo
#' @return A data frame with S3 class \code{git_history}, solely for printing
#'   purposes. Variables: the \code{SHA}, commit \code{message}, \code{when} the
#'   commit happened, \code{author}, \code{email}, and a list-column of objects
#'   of class \code{\linkS4class{git_commit}}.
#' @export
#' @examples
#' repo <- git_init(tempfile("git-history-"))
#' owd <- setwd(repo)
#' line1 <- "Thelma: You're a real live outlaw, aren't ya?"
#' line2 <- paste("J.D.: Well I may be an outlaw, darlin', but you're the one",
#'                "stealing my heart.")
#' write(line1, "tl.txt")
#' git_commit("tl.txt", message = "first commit")
#' write(line2, "tl.txt", append = TRUE)
#' git_commit("tl.txt", message = "second commit")
#' git_history()
#' setwd(owd)
git_history <- function(repo = ".", n = NULL) {
  gr <- as.git_repository(repo)
  ghistory <- tibble::as_tibble(methods::as(gr, "data.frame"))
  if (nrow(ghistory) == 0L) {
    message("No commits yet.")
    return(invisible())
  }
  vars <- c("sha", "summary", "when", "author", "email")
  ghistory <- ghistory[vars]
  names(ghistory)[names(ghistory) == "summary"] <- "message"
  commits <- git2r::commits(gr, n = n)
  commits <-
    tibble::tibble(
      sha = purrr::map_chr(commits, methods::slot, "sha"),
      commit = commits
      )
  if (!is.null(n)) {
    ghistory <- ghistory[ghistory$sha %in% commits$sha, ]
  }
  ghistory$commit <- commits$commit[match(ghistory$sha, commits$sha)]
  structure(ghistory, class = c("git_history", class(ghistory)))
}

#' @export
print.git_history <- function(x, ...) {
  x_pretty <- tibble::tibble(
    sha = substr(x$sha, 1, 7),
    message = sprintf("%-24s", ellipsize(x$message, 24)),
    when = format(x$when, format = "%Y-%m-%d %H:%M"),
    author = x$author,
    email = x$email,
    commit = x$commit
  )
  print(x_pretty)
  invisible(x)
}
