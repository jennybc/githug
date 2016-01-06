#' List branches
#'
#' Convenience wrapper around \code{\link[git2r]{branches}} from
#' \code{\link{git2r}}, which coerces the branch list to a data frame.
#'
#' @param where Which branches to list: \code{all} (the default), \code{local}
#'   only, or \code{remote} only.
#' @template repo
#'
#' @return A data frame (or tbl_df) with one row per branch. Variables are
#'   branch name, type (local vs remote), and a list-column of
#'   \code{\linkS4class{git_branch}} objects.
#' @export
#'
#' @examples
#' ## TO DO: come back when I can clone and truly show local v. remote
#' git_branch_list()
git_branch_list <- function(where = c("all", "local", "remote"), repo = ".") {

  gr <- as_git_repository(as.rpath(repo))
  where <- match.arg(where)
  gb <- git2r::branches(repo = gr, flags = where)
  ## TO DO? submit PR w/ proper coerce method to git2r, like the one to coerce
  ## git_repository objects to data.frame and then use that
  dplyr::data_frame(
    name = purrr::map_chr(gb, slot, "name"),
    type = c("local", "remote")[purrr::map_int(gb, slot, "type")],
    git_branch = gb
    )
}
