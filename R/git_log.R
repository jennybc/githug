#' Show commit log
#'
#' Show commit log. Convenience wrapper around
#' \code{\link[git2r]{coerce-git_repository-method}} from \code{\link{git2r}},
#' which coerces the commits in the repository to a data frame. The print method
#' shows compact versions of, e.g., the commit message, time, and SHA, but rest
#' assured the full information is present in the returned object.
#'
#' @template repo
#' @return A data frame (or tbl_df) with S3 class \code{git_log} for printing
#'   purposes
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
  gr <- as_git_repository(as.rpath(repo))
  vars <- c("message", "when", "author", "sha", "email", "summary")
  ret <- as(gr, "data.frame")[vars]
  if (is.null(ret)) {
    message("no commits yet")
    return(invisible(NULL))
  }
  ret <- dplyr::tbl_df(ret)
  structure(ret, class = c("git_log", class(ret)))
}

#' @export
print.git_log <- function(x, ...) {
  x %>%
    dplyr::mutate_(message = ~ ellipsize(message, 24),
                   when = ~ format(when, "%Y-%m-%d %H:%M"),
                   sha = ~ ellipsize(sha, 7, ellipsis = FALSE),
                   summary = ~ ellipsize(summary, 24)) %>%
    print()
}

ellipsize <- function(x, n = 20, ellipsis = TRUE) {
  if (ellipsis) {
    ellipsis <- "\u2026"
    n <- n - 1
  } else {
    ellipsis <- ''
  }
  ifelse(nchar(x) > n + nchar(ellipsis),
         paste0(substring(x, first = 1, last = n), ellipsis),
         x)
}
