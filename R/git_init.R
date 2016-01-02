#' Create a new Git repository
#'
#' @param path Where to create the new Git repo. If the directory doesn't exist,
#'   it will be created via \code{dir.create(path, recursive = TRUE)}.
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
git_init <- function(path = ".") {

  path <- normalizePath(path, mustWork = FALSE)
  if (dir.exists(path)) {
    if (!is.null(as.grepo(path)))
      message(path, " appears to already be a git repo!")
  } else {
    message("Creating directory ", path)
    dir.create(path, recursive = TRUE)
  }

  message("Doing `git init` in ", path)
  repo <- git2r::init(path)
  return(invisible(as.rpath(repo)))

}
