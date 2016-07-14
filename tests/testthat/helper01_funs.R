tmp_repo_path <-
  function(x = "", slug = "githug-test", user = Sys.info()["user"]) {
    if (x != "") x <- paste0(x, "-")
    tempfile(paste(slug, user, x, sep = "-"))
  }

init_tmp_repo <- function(x = "",
                          slug = "githug-test",
                          user = Sys.info()["user"]) {
  tpath <- tmp_repo_path(x = x, slug = slug, user = user)
  ## switch back to githug::git_init() once it exists again?
  dir.create(tpath)
  system(paste("git init", normalizePath(tpath)), intern = TRUE)
  normalizePath(tpath)
}
