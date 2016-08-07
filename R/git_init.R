#' Create a new Git repository
#'
#' Create a new Git repository or re-initialize an existing one, similar to
#' \code{git init}.
#'
#' Will bad things happen if you \code{git_init()} in a directory that is
#' already a Git repo? No, it's fine! To quote the
#' \href{https://git-scm.com/docs/git-init}{git-init man page}, "running
#' \code{git init} in an existing repository is safe. It will not overwrite
#' things that are already there". A legitimate reason to do this is to pick up
#' a new Git template, a topic which newcomers can safely ignore.
#'
#' \code{git_init()} will not create a Git repo in a subdirectory of an existing
#' Git repo. The proper way to do this is via
#' \href{https://git-scm.com/book/en/v2/Git-Tools-Submodules}{Git submodules},
#' which is beyond the current scope of the package.
#'
#' @param path Where to create the new Git repo. Defaults to current working
#'   directory. If the \code{path} doesn't exist, it will be created via
#'   \code{dir.create(path, recursive = TRUE)}.
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
#' ## Config local user and make a commit
#' git_config(user.name = "thelma", user.email = "thelma@example.org")
#' write("I don't ever remember feeling this awake.", "thelma.txt")
#' git_commit("thelma.txt", message = "thelma is awake")
#' \dontrun{
#' ## remove dontrun when git_log() exists again
#' git_log()
#' }
#'
#' setwd(owd)
git_init <- function(path = ".") {

  path <- normalize_path(path)
  led_path <- least_existing_dir(path)
  printable_path <-
    midlipsize(path, getOption("width") - 2, ellipsis = " \u2026 ")

  if (is_a_repo(path)) {
    message("'path' is already a Git repo:\n  ", printable_path)
  } else if (is_in_repo(led_path)) {
    stop("Aborting git_init().\n",
         "'path' is or will be nested within an existing Git repo:\n  ",
         printable_path, call. = FALSE)
  }

  if (!dir_exists(path)) {
    if (file_exists(path)) {
      stop("Aborting git_init().\n",
           "Can't create directory. File already exists at 'path':\n  ",
           printable_path, call. = FALSE)
    }
    message("* Creating directory:\n  ", printable_path)
    dir.create(path, recursive = TRUE)
  }

  message("* Initialising git repository in:\n  ", printable_path)
  gr <- git2r::init(path)
  return(invisible(gr_path(gr)))

  ## TO CONSIDER:
  ## set any custom githug config vars here? note that githug did git_init()?
  ## add hooks?
  ## https://github.com/jennybc/githug0/issues/11
  ## set standard config vars to superior non-default values now?
  ## https://github.com/jennybc/githug0/issues/7

}
