## for travis, etc. set some global config
gcfg <- git_config_global()
if (length(gcfg) == 0L)
  git_config_global(user.name = "ci", user.email = "ci@example.org")

## make sure current wd is or is inside a git repo
## why? so local git config exists
suppressMessages(
  git_init(".")
)
