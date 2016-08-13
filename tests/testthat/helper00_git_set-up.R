## make sure current wd is or is inside a git repo
## why? so local git config exists
## matters even during local R CMD check, not to mention on travis, etc.
if (!is_in_repo()) {
  git_init()
}
