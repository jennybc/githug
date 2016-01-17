#' Create a new Git repository
#'
#' @param path Where to create the new Git repo. Defaults to current working
#'   directory. If the \code{path} doesn't exist, it will be created via
#'   \code{dir.create(path, recursive = TRUE)}.
#' @param force Whether to create a Git repo, even if it will be inside another
#'   repo. This is generally a bad idea, so use \code{force = TRUE} at your own
#'   risk and consider using Git submodules instead.
#'
#' @template return-repo-path
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("git-init-example-"))
#'
#' ## switch working directory to the repo
#' owd <- setwd(repo)
#'
#' ## Config user and make a commit
#' git_config(user.name = "thelma", user.email = "thelma@example.org")
#' writeLines("I don't ever remember feeling this awake.", "thelma.txt")
#' git_COMMIT("thelma is awake")
#' git_log()
#'
#' setwd(owd)
git_init <- function(path = ".", force = FALSE) {

  path <- normalizePath(path, winslash = "/", mustWork = FALSE)
  path_preexists <- dir.exists(path)
  path_is_repo   <- is_a_repo(path)

  led_path       <- least_existing_dir(path)
  led_is_in_repo <- is_in_repo(led_path)

  if (path_preexists && path_is_repo) {
    message("'path' appears to already be a Git repo:\n", path)
  }

  ## could be just 'if (led_is_in_repo)' but want to avoid double message
  if (  (path_preexists && !path_is_repo && led_is_in_repo) ||
       (!path_preexists && led_is_in_repo) ) {
    message("'path' is or will be nested within an existing Git repo:\n", path)
    if (!force) {
      message("If you really want to init a new repo inside an existing ",
              "repo, use 'git_init(path, force = TRUE)'.")
      return(invisible(NULL))
    }
  }

  if (!path_preexists) {
    message("Creating directory ", path)
    dir.create(path, recursive = TRUE)
  }

  message("Doing `git init` in ", path)
  repo <- git2r::init(path)
  return(invisible(as.rpath(repo)))

}
