## for travis, etc. set some global config
gcfg <- git_config_global()
if (length(gcfg) == 0L)
  git_config_global(user.name = "ci", user.email = "ci@example.org")

## make sure current wd is or is inside a git repo
## why? so local git config exists
suppressMessages(
  git_init(".")
)

## other repos used in tests
path <- "repo01-blah"

if (!dir.exists(path)) {

  message("creating repo01-blah!")
  ## I don't use git_init() because I actually WANT to create a git repo
  ## within a git repo here
  dir.create(path)
  repo <- git2r::init(path)
  git_config_local(repo = repo,
                   user.name = "jane", user.email = "jane@example.org")

}
