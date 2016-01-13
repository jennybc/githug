#' Retrieve GitHub personal access token.
#'
#' Consults environment variables for a GitHub personal access token (PAT). By
#' default, looks for \code{GITHUB_PAT} and \code{GITHUB_TOKEN}, in that order.
#' Conventions followed by other packages at the time of writing:
#' \code{\link{git2r}} and \code{devtools} look for \code{GITHUB_PAT},
#' \code{\link{gh}} looks for \code{GITHUB_TOKEN}. Obtain a PAT from
#' \url{https://github.com/settings/tokens}. Unless you have a specific reason
#' to request otherwise, the default scopes are probably sufficient.
#'
#' How to store your PAT in an environment variable?
#'
#' \itemize{
#'
#' \item Identify your home directory. Not sure? Enter
#' \code{normalizePath("~/")} in the R console.
#'
#' \item If you don't already have a file here named \code{.Renviron}, create
#' one. If you have one already, open it for editing.
#'
#' \item Add a line like this: \code{GITHUB_PAT=blahblahblahblahblahblah}, where
#' \code{blahblahblahblahblahblah} is your PAT. Make sure the last line in the
#' file is empty. Otherwise R will \strong{silently} fail to load the file.
#' Save. And yes you do want to use a filiename that begins with a dot.
#'
#' \item Restart R. \code{.Renviron} is processed only during
#' \code{\link{Startup}}.
#'
#' \item Check your work with \code{Sys.getenv("GITHUB_PAT")}. Your PAT should
#' print to screen.
#'
#' }
#'
#' @param envvar Name of the environment variable in which the GitHub personal
#'   access token is stored. Can be a character vector, with names in order of
#'   preference
#'
#' @return The GitHub personal access token, invisibly.
#' @export
#' @examples
#' ## by default, the PAT is not printed to screen
#' gh_pat()
#'
#' ## if you really want to see it, surround the call with extra parentheses
#' (gh_pat())
gh_pat <- function(envvar = c("GITHUB_PAT", "GITHUB_TOKEN")) {
  ## part of reason for name gh_pat vs github_pat is to not mask
  ## devtools::github_pat
  stopifnot(inherits(envvar, "character"), length(envvar) > 0)
  ## if only one element comes back, name gets dropped, so restore it
  candidates <- stats::setNames(Sys.getenv(envvar), envvar)
  candidates <- candidates[candidates != ""]
  if (length(candidates) < 1) {
    message(paste("Can't find env var to use as GitHub personal access token",
                  "under these names:\n"),
            paste(envvar, collapse = "\n"))
    candidates <- ""
  } else {
    message("GitHub personal access token found in env var ",
            names(candidates)[1])
  }
  invisible(candidates[1])
}

## https://developer.github.com/v3/#authentication
##
## devtools uses Basic Authentication, like so:
# github_auth <- function(token) {
#   if (is.null(token)) {
#     NULL
#   } else {
#     httr::authenticate(token, "x-oauth-basic", "basic")
#   }
# }
## then calls httr::VERBs like so:
# httr::VERB(url, auth, ...)
## i.e. prepared token gets mopped up into "Further named parameters, such as
## query, path, etc, passed on to modify_url"
##
## gh uses OAuth2 Token and therefore sends in a header
## token is prepped like so:
# get_auth <- function(token) {
#   auth <- character()
#   if (token != "") auth <- c("Authorization" = paste("token", token))
#   auth
# }
# auth <- get_auth(token)
## then httr::VERBs are called like so:
# httr::VERB(url, add_headers(.headers = c(headers, auth = auth), ...))
#
## since top-level fxns from gh just want the token, that's what we'll provide
## following gh convention re: sending "" (not NULL) when PAT not found
