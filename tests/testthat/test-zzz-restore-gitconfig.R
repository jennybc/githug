if (file.copy(from = file.path("~", ".gitconfig_BAK"),
              to =  file.path("~", ".gitconfig"),
              overwrite = TRUE))
  file.remove(file.path("~", ".gitconfig_BAK"))

