## make sure current wd is or is inside a git repo
## why? so local git config exists
## matters even during local R CMD check
suppressMessages(
  #git_init(".")
  system(paste("git init", normalizePath(".")), intern = TRUE)
)
