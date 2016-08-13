#' Make a commit
#'
#' Write file changes to the repository. Convenience wrapper around
#' \code{\link[git2r:commit]{git2r::commit}()} and, possibly,
#' \code{\link{git_stage}()}. To stage and commit all current file additions,
#' deletions, and modifications, use \code{git_commit(all = TRUE)}, which
#' emulates \code{git add -A && git commit}.
#'
#' If there are staged changes, the simple call \code{git_commit(message = "my
#' message")} makes a commit. In the absence of staged changes or when paths are
#' given via \code{...}, \code{\link{git_stage}()} is called, with arguments
#' \code{all} and \code{force} also being passed through.
#'
#' @inheritParams git_stage
#' @param message The commit message. Required. If not supplied, user will get a
#'   chance to provide the message in an interactive session.
#' @template repo
#' @template return-SHA-with-hint
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "max.txt")
#' write("You get what you settle for.", "louise.txt")
#' git_status()
#' git_commit(all = TRUE,
#'            message = "Brains'll only get you so far and luck always runs out.")
#' write("If done properly armed robbery doesn't have to be a totally unpleasant experience.",
#'       "jd.txt")
#' git_status()
#' git_commit("jd.txt", message = "J.D. is charming")
#' setwd(owd)
#' @export
git_commit <- function(..., all = FALSE, force = FALSE,
                       message = NULL, repo = ".") {
  gr <- as.git_repository(repo)
  path <- as.character(c(...))
  stopifnot(is_lol(force))
  if (is.null(message) && !interactive()) {
    stop("You must provide a commit message. Aborting.", call. = FALSE)
  }

  n_path <- length(path)
  if (n_path == 0L) {
    st <- git_status(repo = repo)
    n_staged <- sum(st$status == "staged")
  }

  if (n_path > 0L || n_staged == 0L) {
    ## faithfully transmit missingness of 'all'
    sargs <- list(path = path, force = force, repo = repo)
    if (!missing(all)) {
      sargs$all <- all
    }
    do.call(git_stage, sargs)
  }

  st <- git_status(repo = repo)
  n_staged <- sum(st$status == "staged")

  if (n_staged == 0L) {
    warning("Nothing staged for commit.")
    return(invisible())
  }

  if (is.null(message) && interactive()) {
    message <- get_user_input("You must provide a commit message.",
                              "Enter it now (ESC to abort)")
  }

  ## command line git would say something like this:
  ##  1 file changed, 5 insertions(+), 5 deletions(-)
  ## should I also indicate something about the nature of the changes?
  ## if I'm going to say that, maybe do it before prompting for message?
  gco <- git2r::commit(repo = gr, message = message)
  message("Commit:\n", bulletize_git_commit(gco))
  invisible(sha_with_hint(gco))
}
