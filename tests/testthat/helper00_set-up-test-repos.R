## for travis, etc. set some global config
gcfg <- git_config_global()
if (length(gcfg) == 0L)
  git_config_global(user.name = "ci", user.email = "ci@example.org")

## if current wd not already inside a git repo, git init
## why? so local git config exists
curr_git <- git2r::discover_repository(".")
if (is.null(curr_git))
  git2r::init(".")

## other repos used in tests
path <- "repo01-blah"

if (!dir.exists(path)) {

  message("creating repo01-blah!\n\n")
  dir.create(path)
  repo <- git2r::init(path)
  git2r::config(repo, user.name = "jane", user.email = "jane@example.org")

}
