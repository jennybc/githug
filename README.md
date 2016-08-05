
<!-- README.md is generated from README.Rmd. Please edit that file -->
``` r
Sys.time()
#> [1] "2016-08-05 11:23:58 PDT"
git2r::repository(".")
#> Local:    git-init-status-commit-add /Users/jenny/rrr/githug0/
#> Remote:   git-init-status-commit-add @ origin (https://github.com/jennybc/githug0.git)
#> Head:     [e915179] 2016-08-04: test helpers
covr::package_coverage(".")
#> githug Coverage: 91.35%
#> R/utils.R: 73.81%
#> R/git_add-stage.R: 83.33%
#> R/git_commit.R: 94.44%
#> R/git_config.R: 100.00%
#> R/git_init.R: 100.00%
#> R/git_repository.R: 100.00%
#> R/git_status.R: 100.00%
#> R/githug_list-class.R: 100.00%
```
