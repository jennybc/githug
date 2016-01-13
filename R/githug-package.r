#' githug
#'
#' @name githug
#' @importFrom dplyr %>%
#' @importFrom purrr %||%
#' @docType package
NULL

if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))

.githug <- new.env(parent = emptyenv())

## custom git variables we potentially define in the "githug" section
##
## mostly taken from the return value of
## https://developer.github.com/v3/repos/#get
## GET /repos/:owner/:repo
##
## NOTE! git config vars can't contain underscores
## the names below are they way they are because of GitHub API
## but prior to git config hte names are pre-processed:
## underscores replace by ''
## custom 'githug' section must be prepended
## example:
## 'full_name' --> 'githug.fullname'
assign("githug_config",
       c("user",        ## jennybc
         "org",         ## for future ...
         "name",        ## githug
         "full_name",   ## jennybc/githug
         "private",     ## TRUE or FALSE
         "html_url",    ## https://github.com/jennybc/githug
         "description", ## "Interface to local and remote ..."
         "protocol",    ## https or ssh
         "ssh_url",     ## git@github.com:jennybc/githug.git
         "clone_url",   ## https://github.com/jennybc/githug.git
         "remote_name", ## origin
         "fork",        ## TRUE or FALSE
         "fork_origin_full_name",  ## e.g., hadley/devtools
         ## get this as .$parent$full_name
         ## I note the uber-parent is available as source ...
         "fork_origin_remote_name" ## fork-origin
       ),
       envir = .githug)
