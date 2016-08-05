ddd-processing.R
================
jenny
Mon Jul 25 16:24:05 2016

-   [`renquote()`](#renquote)
-   [`list_depth_one()`](#list_depth_one)

``` r
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  error = TRUE
)
```

I have some rather useful functions for processing very diverse `...` input to `git_config()` but damn if I remember how they work. And I may need this stuff again for `git_add()`.

### `renquote()`

Here it is and apparently I was inspired by [a question from Jeroen on stackoverflow](http://stackoverflow.com/questions/19734412/flatten-nested-list-into-1-deep-list).

``` r
renquote <- function(l) {
  if (is.list(l)) {
    lapply(l, renquote) }
  else if (length(l) > 1) {
    lapply(as.list(l), renquote)
  } else {
    enquote(l)
  }
}

x <- list(foo = TRUE, bar = 456, baz = NULL,
          pets = list(cat = "meeuw", dog = "woof"),
          letters = c(a = "a", b = "b", c = "c"))
renquote(x)
#> $foo
#> quote(TRUE)
#> 
#> $bar
#> quote(456)
#> 
#> $baz
#> quote(NULL)
#> 
#> $pets
#> $pets$cat
#> quote("meeuw")
#> 
#> $pets$dog
#> quote("woof")
#> 
#> 
#> $letters
#> $letters$a
#> quote("a")
#> 
#> $letters$b
#> quote("b")
#> 
#> $letters$c
#> quote("c")
```

This appears to recurse through the input list and apply `enquote()` to each atom, by which I mean a list or vector element that is itself neither a list nor a vector of length greater than 1. `enquote()` is described as "a simple one-line utility which transforms a call of the form `Foo(....)` into the call `quote(Foo(....))`. This is typically used to protect a call from early evaluation."

### `list_depth_one()`

I then use `renquote()` inside another function, `list_depth_one()`, like so:

``` r
list_depth_one <- function(x) lapply(unlist(renquote(x)), eval)
```

So here we go

``` r
list_depth_one(x)
#> $foo
#> [1] TRUE
#> 
#> $bar
#> [1] 456
#> 
#> $baz
#> NULL
#> 
#> $pets.cat
#> [1] "meeuw"
#> 
#> $pets.dog
#> [1] "woof"
#> 
#> $letters.a
#> [1] "a"
#> 
#> $letters.b
#> [1] "b"
#> 
#> $letters.c
#> [1] "c"
```

And why wasn't I content with `unlist()`?

``` r
unlist(x)
#>       foo       bar  pets.cat  pets.dog letters.a letters.b letters.c 
#>    "TRUE"     "456"   "meeuw"    "woof"       "a"       "b"       "c"
```

The `NULL` is dropped and you get a vector, not a list, back. Both of which matter for `git_config()`. I also note that everything gets coerced to character, which doesn't happen to be a problem for `git_config()` but is still a big difference.

I think `unlist()` might actually get the job done in `git_add()`.
