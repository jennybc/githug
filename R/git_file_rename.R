#' Rename or move a file and stage both ends
#'
#' Rename a file and stage both ends of the transaction, i.e. the deletion of
#' the file under its original name and the addition of the file under its new
#' name. You still need to make the commit. If Git recognizes a rename event,
#' then the history of the file will be preserved. This is worth striving for.
#' Maximize the chance of this happy event by making the rename/move a distinct
#' operation that is not muddled up with other changes to the file.
#'
#' This is an extremely simple implementation of basic \code{git mv}. Why? True
#' \code{git mv} is offered neither by libgit2 nor, therefore, by
#' \code{\link{git2r}}.
#'
#' @param from Path to an existing file, relative to the repo working directory
#' @param to The desired new name, relative to the repo working directory
#' @template repo
#'
#' @return Nothing
#'
#' @export
#'
#' @examples
#' repo <- git_init(tempfile("githug-"))
#' owd <- setwd(repo)
#' write("Are these girls real smart or real real lucky?", "louise.txt")
#' git_commit(all = TRUE, message = "filename is all wrong")
#' git_mv(from = "louise.txt", to = "max.txt")
#' git_commit(all = TRUE, message = "corrected filename")
#' git_history()
#' setwd(owd)
git_file_rename <- function(from, to, repo = ".") {
  stopifnot(is.character(from), length(from) == 1L)
  stopifnot(is.character(to), length(to) == 1L)
  from_path <- file.path(repo_path(repo), from)
  to_path <- file.path(repo_path(repo), to)
  stopifnot(file_exists(from_path), !file_exists(to_path))
  ok <- file.rename(from = from_path, to = to_path)
  if (!ok) {
    stop("Unable to rename '", from, "' to '", to, "'", call. = FALSE)
  }
  message("File renamed:\n  * '", from, "' --> '", to, "'")
  git_stage(from, to, repo = repo)
  invisible()
}

#' @rdname git_file_rename
#' @export
git_mv <- git_file_rename
