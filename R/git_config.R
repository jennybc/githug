#' Get and set Git configuration variables
#'
#' \code{git_config} and convenience wrappers \code{git_config_global} and
#' \code{git_config_local} can be used to query or modify Git configuration.
#'
#' Variables can be set by specifying them as arguments in \code{variable =
#' value} form or as a named list. To unset a variable, i.e. \code{git config
#' --unset}, specify \code{NULL} as the value. Variables can be queried by
#' specifying the names as strings or in a list or vector of strings.
#'
#' When variables are set, the previous values are returned in an invisible
#' named list, analogous to \code{\link{par}} or \code{\link{setwd}}. Such a
#' list can be passed back in to \code{git_config_local} or
#' \code{git_config_global} to restore the previous configuration.
#'
#' When setting, the inclusion of non-standard variable names leads to silent
#' failure. Consult the \href{https://git-scm.com/docs/git-config}{git-config
#' man page} for a long yet non-comprehensive list of variables. When querying,
#' non-existent variable names return \code{NULL}.
#'
#' @param ... The Git configuration variables to get or set. If unspecified, all
#'   are returned, i.e. the output should match the result of \code{git config
#'   --list}.
#' @param repo Path to a Git repo. If unspecified, current working directory is
#'   checked to see if it is or is inside a Git repo.
#' @param where Specifies which options. The default, \code{de_facto}, applies
#'   only to a query and requests the options in force, i.e. where local repo
#'   options override global user-level options, when both exist. \code{local}
#'   or \code{global} narrows the scope to the associated configuration file.
#'   When setting, if \code{where} is unspecified, the local configuration is
#'   modified.
#'
#' @return A named list of Git configuration variables.
#' @export
#'
#' @references
#'
#' \href{https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup}{Getting
#' Started - First-Time Git Setup} from the Pro Git book by Scott Chacon and Ben
#' Straub
#'
#' \href{https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration}{Customizing
#' Git - Git Configuration} from the Pro Git book by Scott Chacon and Ben Straub
#'
#' \href{https://git-scm.com/docs/git-config}{git-config man page}
#'
#' @examples
#' ## see git config currently in effect, based on working directory
#' git_config()         # local > global, same as git_config(where = "de_facto")
#' git_config_local()   #                 same as git_config(where = "local")
#' git_config_global()  #                 same as git-config(where = "global")
#'
#' \dontrun{
#' ## set and query global config
#' git_config_global(user.name = "thelma", user.email = "thelma@example.org")
#' git_config_global("user.name", "user.email")
#' }
#'
#' ## specify a Git repo
#' ## TO DO: edit once git2r::init is wrapped
#' path <- tempfile(pattern = "githug-example-")
#' dir.create(path)
#' repo <- git2r::init(path)
#' repo <- git2r::workdir(repo)
#' git_config_local(repo = repo)
#'
#' ## switch working directory to the repo
#' owd <- setwd(path)
#'
#' ## set local variables for current repo
#' git_config_local(user.name = "louise", user.email = "louse@example.org")
#'
#' ## query specific local variables
#' git_config_local("user.name", "color.branch", "user.email")
#'
#' ## set local variables, then restore
#' ocfg <- git_config_local(user.name = "oops", user.email = "oops@example.org")
#' git_config_local("user.name", "user.email")
#' git_config_local(ocfg)
#' git_config_local("user.name", "user.email")
#'
#' setwd(owd)
git_config <- function(..., repo = NULL,
                       where = c("de_facto", "local", "global")) {

  if (!is.null(repo)) {
    repo <- as.grepo(repo)
    repo <- as_git_repository(repo)
  }
  where <- match.arg(where)

  ddd <- list_depth_one(list(...))
  setting <- is_named(ddd)

  if (setting) {
    if (where == "de_facto") {
      message("setting local config")
      where <- "local"
    }
    ocfg <- git2r::config(repo = repo)[[where]]
    cargs <- c(repo = repo, global = where == "global", ddd)
    ncfg <- do.call(git2r::config, cargs)
    return(invisible(screen(ocfg, names(ddd))))
  }

  ## querying
  cfg <- git2r::config(repo = repo)
  if (is.null(cfg$local))
    cfg$local <- list()
  cfg <- switch(where,
                de_facto = modifyList(cfg$global, cfg$local),
                local = cfg$local,
                global = cfg$global)
  ddd <- list_to_chr(ddd)
  screen(cfg, ddd)
}

#' @describeIn git_config Get or set global Git config, a la \code{git config
#'   --global}
#' @export
git_config_global <-
  function(...) git_config(..., repo = NULL, where = "global")

#' @describeIn git_config Get or set local Git config, a la \code{git config
#'   --local}
#' @export
git_config_local <-
  function(..., repo = NULL) git_config(..., repo = repo, where = "local")
