#' Get the commit history
#'
#' Get an overview of the last \code{n} commits. Convenience wrapper around
#' \code{\link[git2r:commits]{git2r::commits}()}. The print method shows
#' truncated versions of selected variables, e.g., the commit message, time, and
#' SHA, but rest assured the full information is present in the returned object.
#'
#' @template repo
#' @param ... Optional parameters passed through to
#'   \code{\link[git2r:commits]{git2r::commits}()}. Can include:
#'   \itemize{
#'   \item \code{n} Max number of commits.
#'   \item \code{topological} Logical, requests topological sort, i.e.
#'   parent before child, defaults to \code{TRUE}. Can be combined with
#'   \code{time}.
#'   \item \code{time} Logical, requests chronological sort, defaults to
#'   \code{TRUE}. Can be combined with \code{topological}.
#'   \item \code{reverse} Logical, reverses the order, defaults to
#'   \code{FALSE}.
#'   }
#' @return A data frame with S3 class \code{git_history}, solely for printing
#'   purposes. Variables: the \code{SHA}, commit \code{message}, \code{when} the
#'   commit happened, \code{author}, and \code{email}.
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
git_history <- function(repo = ".", ...) {
  commits <- git2r::commits(as.git_repository(repo), ...)
  if (length(commits) == 0L) {
    message("No commits yet.")
    return(invisible())
  }
  raw_author <- purrr::map(commits, methods::slot, "author")
  ctbl <- tibble::tibble(
        sha = purrr::map_chr(commits, methods::slot, "sha"),
    message = purrr::map_chr(commits, methods::slot, "message"),
       when = purrr::map(raw_author, methods::slot, "when"),
     author = purrr::map_chr(raw_author, methods::slot, "name"),
      email = purrr::map_chr(raw_author, methods::slot, "email")
  )
  ctbl$when <- purrr::map(ctbl$when, ~ methods::as(.x, "POSIXct"))
  ctbl$when <- do.call(c, ctbl$when)
  structure(ctbl, class = c("git_history", class(ctbl)))
}

#' @export
print.git_history <- function(x, ...) {
  x_pretty <- tibble::tibble(
    sha = substr(x$sha, 1, 7),
    message = sprintf("%-24s", ellipsize(x$message, 24)),
    when = format(x$when, format = "%Y-%m-%d %H:%M"),
    author = x$author,
    email = x$email
  )
  print(x_pretty)
  invisible(x)
}
