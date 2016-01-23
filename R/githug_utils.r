githug_name <- function(path = ".") {
  rproj <- list.files(path = path, pattern = ".*\\.Rproj$")
  projdir <- basename(path)
  choices <- tools::file_path_sans_ext(c(rproj, projdir))
  choices[1]
}

githug_README <- function(path = ".", name = NULL, description = NULL) {

  name <- name %||% githug_name(path = path)
  description <- description %||% "R work of staggering genius"

  fls <- list.files(path = path, pattern = "^README\\.md$", full.names = TRUE)
  cat(fls, "\n")
  if (length(fls) > 0) {
    message("Existing README.md found and preserved.")
    return(invisible(normalizePath(fls[1], winslash = "/")))
  }

  rm_path <- file.path(path, "README.md")
  message("Creating README.md")
  writeLines(sprintf("# %s\n\n%s", name, description), rm_path)

  invisible(normalizePath(rm_path, winslash = "/"))
}

