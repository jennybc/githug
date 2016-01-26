## some evolution of this should be exported ... but what?
## also it should return something less unwieldy ... but what?
gh_repo_list <- function(
  username = NULL, org = NULL, pat = NULL, ..., .limit = Inf) {

  if (is.null(username) && is.null(org)) {
    res <- repo_list_pat(pat, ..., .limit = .limit)
  }

  if (!is.null(username)) {
    if( !is.null(org)) {
      message("Ignoring 'org', since 'username' was provided and takes",
              "precedence")
    }
    res <- repo_list_username(username, ..., .limit = .limit)
  }

  if( !is.null(org)) {
    res <- repo_list_org(org, pat, ..., .limit = .limit)
  }

  res

}

repo_list_pat <- function(pat, ..., .limit = Inf) {
  ## List repositories that are accessible to the authenticated user.
  ## https://developer.github.com/v3/repos/#list-your-repositories
  ## GET /user/repos

  ## NOTE: I am NOT making this any of my business now / yet. JUST FYI.
  ## visibility | string | Can be one of all, public, or private.
  ##    Default: all
  ## affiliation | string | Comma-separated list of values. Can include:
  ##  * owner: Repositories that are owned by the authenticated user.
  ##  * collaborator: Repositories that the user has been added to as a
  ##    collaborator.
  ##  * organization_member: Repositories that the user has access to through
  ##    being a member of an organization. This includes every repository on
  ##    every team that the user is on.
  ##    Default: owner,collaborator,organization_member
  ## type | string | Can be one of all, owner, public, private, member.
  ##    Default: all
  ##    Will cause a 422 error if used in the same request as visibility or affiliation.
  ## sort | string | Can be one of created, updated, pushed, full_name.
  ##    Default: full_name
  ## direction | string | Can be one of asc or desc.
  ##    Default: when using full_name: asc; otherwise desc

  message("Listing repos accessible to GitHub user associated with 'pat'")
  pat <- pat %||% gh_pat()
  gh::gh("/user/repos", ..., .token = pat, .limit = .limit)
}

repo_list_username <- function(username, ..., .limit = Inf) {
  ## List public repositories for the specified user.
  ## https://developer.github.com/v3/repos/#list-user-repositories
  ## GET /users/:username/repos

  ## NOTE: I am NOT making this any of my business now / yet. JUST FYI.
  ## type | string | Can be one of all, owner, member.
  ##     Default: owner
  ## sort | string | Can be one of created, updated, pushed, full_name.
  ##     Default: full_name
  ## direction | string | Can be one of asc or desc.
  ##     Default: when using full_name: asc, otherwise desc

  message("Listing public repos for the GitHub user:\n  ", username)
  gh::gh("/users/:username/repos", username = username, ..., .limit = .limit)
}

repo_list_org <- function(org, pat, ..., .limit = Inf) {
  ## List repositories for the specified org.
  ## https://developer.github.com/v3/repos/#list-organization-repositories
  ## GET /orgs/:org/repos

  ## NOTE: I don't want to make this my business.
  ## But I fear I must because we need to send 'pat' in some cases?
  ## I can get by for now because gh will look for GITHUB_TOKEN and find it.
  ## Or you can specify .token in `...` and it gets passed through.
  ## type | string | Can be one of all, public, private, forks, sources, member.
  ##     Default: all

  message("List repositories for the GitHub Organization:\n  ", org)
  gh::gh("/orgs/:org/repos", org = org, ..., .limit = .limit)
}
