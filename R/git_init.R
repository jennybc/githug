#' Create a new Git repository
#'
#' @param path Where to create the new Git repo. If the directory doesn't exist,
#'   it will be created via \code{dir.create(path, recursive = TRUE)}.
#' @param force Whether to create a Git repo, even if it appears to be inside
#'   another repo. This is generally a bad idea, so use \code{force = TRUE} at
#'   your own risk and consider using Git submodules instead.
#'
#' @return character, the path to the repository
#' @export
#'
#' @examples
#' repo <- tempfile(pattern = "githug-init-example-")
#' git_init(repo)
#'
#' ## switch working directory to the repo
#' owd <- setwd(repo)
#'
#' ## Config user and make a commit
#' git_config(user.name="thelma", user.email="thelma@example.org")
#' writeLines("I don't ever remember feeling this awake.", "example.txt")
#' ## TO DO: revisit once I've wrapped add, status, commit, etc.
#' git2r::add(as_git_repository(), "example.txt")
#' git2r::status(as_git_repository())
#' git2r::commit(as_git_repository(), "thelma is awake")
#' git2r::commits(as_git_repository())[[1]]
#'
#' setwd(owd)
git_init <- function(path = ".", force = FALSE) {

  path <- normalizePath(path, mustWork = FALSE)
  path_preexists <- dir.exists(path)
  led_path <- least_existing_dir(path)
  enclosing_repo <- as.rpath(led_path)
  path_is_repo <- identical(path, enclosing_repo)
  led_is_in_repo <- !is.null(enclosing_repo)

  if (path_preexists && path_is_repo) {
    message("'path' appears to already be a Git repo:\n", path)
  }

  if ( (path_preexists && !path_is_repo && led_is_in_repo) ||
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
