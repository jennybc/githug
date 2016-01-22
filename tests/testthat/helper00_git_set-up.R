## for travis, etc. set some global config
gcfg <- git_config_global()
if (length(gcfg) == 0L) {
  git_config_global(user.name = "ci", user.email = "ci@example.org")
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
