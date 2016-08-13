#' Get a commit log
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
#' @return A data frame with S3 class \code{git_log}, solely for printing
#'   purposes. Variables: the \code{SHA}, commit \code{message}, \code{when} the
#'   commit happened, \code{author}, \code{email}, and a list-column of objects
#'   of class \code{\linkS4class{git_commit}}.
#' @export
#' @examples
#' repo <- git_init(tempfile("git-log-"))
#' owd <- setwd(repo)
#' line1 <- "Thelma: You're a real live outlaw, aren't ya?"
#' line2 <- paste("J.D.: Well I may be an outlaw, darlin', but you're the one",
#'                "stealing my heart.")
#' write(line1, "tl.txt")
#' git_commit("tl.txt", message = "first commit")
#' write(line2, "tl.txt", append = TRUE)
#' git_commit("tl.txt", message = "second commit")
#' git_log()
#' setwd(owd)
git_log <- function(repo = ".", n = NULL) {
  gr <- as.git_repository(repo)
  glog <- tibble::as_tibble(methods::as(gr, "data.frame"))
  if (nrow(glog) == 0L) {
    message("No commits yet.")
    return(invisible())
  }
  vars <- c("sha", "summary", "when", "author", "email")
  glog <- glog[vars]
  names(glog)[names(glog) == "summary"] <- "message"
  commits <- git2r::commits(gr, n = n)
  commits <-
    tibble::tibble(
      sha = purrr::map_chr(commits, methods::slot, "sha"),
      commit = commits
      )
  if (!is.null(n)) {
    glog <- glog[glog$sha %in% commits$sha, ]
  }
  glog$commit <- commits$commit[match(glog$sha, commits$sha)]
  structure(glog, class = c("git_log", class(glog)))
}

#' @export
print.git_log <- function(x, ...) {
  x_pretty <- tibble::tibble(
    sha = substring(x$sha, 1, 7),
    message = sprintf("%-24s", ellipsize(x$message, 24)),
    when = format(x$when, format = "%Y-%m-%d %H:%M"),
    author = x$author,
    email = x$email,
    commit = x$commit
  )
  print(x_pretty)
  invisible(x)
}
