path_exists <- function(x) {
  stopifnot(inherits(x, "character"), length(x) == 1L)
  file.exists(normalizePath(x, mustWork = FALSE))
}
