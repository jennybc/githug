## for travis, etc. set some global config
gcfg <- git_config_global()
if (length(gcfg) == 0L) {
  git_config_global(user.name = "githugci", user.email = "githugci@example.org")
}

## make sure current wd is or is inside a git repo
## why? so local git config exists
suppressMessages(
  git_init(".")
)

## get the githugci-PAT if stored in a file
## locally it will be found
## however file is gitignored, so never goes to github or, eg, travis
## on ci, GITHUB_PAT must be in secure env var
if (file.exists("githugci-PAT.txt")) {
  Sys.setenv(GITHUB_PAT = scan("githugci-PAT.txt", what = character(),
                               quiet = TRUE))
}

## do we have an internet connection?
## use for a custom skipper
safe_cfm <- purrr::safely(curl::curl_fetch_memory)
req <- safe_cfm("https://httpbin.org/get")
Sys.setenv(INTERNET = is.null(req$error))
cat("INTERNET = ", Sys.getenv("INTERNET"), "\n")
skip_if_no_internet <- function() {
  if (!identical(Sys.getenv("INTERNET"), "TRUE")) skip("No internet connection")
}
