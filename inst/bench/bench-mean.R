library(profvis)
library(dplyr)
library(vctrs)
library(bench)

bench_mean <- function(n = 1e6, ngroups = 1000) {
  args <- list(n = n, ngroups = ngroups)

  # main, internal_mean
  main_length <- callr::r(args = args, function(n, ngroups) {
    library(dplyr, warn.conflicts = FALSE)
    library(purrr)
    library(vctrs)

    df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
      group_by(g)
    bench::mark(summarise(df, a = length(x))) %>%
      mutate(branch = "main", fun = "length", n = n, ngroups = ngroups) %>%
      select(branch, fun, n, ngroups, min:last_col())
  })

  main_internal <- callr::r(args = args, function(n, ngroups) {
    library(dplyr, warn.conflicts = FALSE)
    library(purrr)
    library(vctrs)

    df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
      group_by(g)
    bench::mark(summarise(df, a = .Internal(mean(x)))) %>%
      mutate(
        branch = "main",
        fun = ".Internal(mean(.))",
        n = n,
        ngroups = ngroups
      ) %>%
      select(branch, fun, n, ngroups, min:last_col())
  })

  main_mean <- callr::r(args = args, function(n, ngroups) {
    library(dplyr, warn.conflicts = FALSE)
    library(purrr)
    library(vctrs)

    df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
      group_by(g)
    bench::mark(summarise(df, a = mean(x))) %>%
      mutate(branch = "main", fun = "mean(.)", n = n, ngroups = ngroups) %>%
      select(branch, fun, n, ngroups, min:last_col())
  })

  released_internal <- callr::r(
    args = args,
    libpath = "../bench-libs/0.8.3",
    function(n, ngroups) {
      library(dplyr, warn.conflicts = FALSE)
      library(purrr)
      library(vctrs)

      df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
        group_by(g)
      bench::mark(summarise(df, a = .Internal(mean(x)))) %>%
        mutate(
          branch = "0.8.3",
          fun = ".Internal(mean(.))",
          n = n,
          ngroups = ngroups
        ) %>%
        select(branch, fun, n, ngroups, min:last_col())
    }
  )

  released_hybrid_mean <- callr::r(
    args = args,
    libpath = "../bench-libs/0.8.3",
    function(n, ngroups) {
      library(dplyr, warn.conflicts = FALSE)
      library(purrr)
      library(vctrs)

      df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
        group_by(g)
      bench::mark(summarise(df, a = mean(x))) %>%
        mutate(
          branch = "0.8.3",
          fun = "hybrid mean(.)",
          n = n,
          ngroups = ngroups
        ) %>%
        select(branch, fun, n, ngroups, min:last_col())
    }
  )

  released_nonhybrid_mean <- callr::r(
    args = args,
    libpath = "../bench-libs/0.8.3",
    function(n, ngroups) {
      library(dplyr, warn.conflicts = FALSE)
      library(purrr)
      library(vctrs)

      mean2 <- function(x, ...) UseMethod("mean")

      df <- tibble(x = rnorm(n), g = sample(rep(1:ngroups, n / ngroups))) %>%
        group_by(g)
      bench::mark(summarise(df, a = mean2(x))) %>%
        mutate(branch = "0.8.3", fun = "mean2(.)", n = n, ngroups = ngroups) %>%
        select(branch, fun, n, ngroups, min:last_col())
    }
  )

  as_tibble(vec_rbind(
    main_length,
    main_internal,
    main_mean,
    released_internal,
    released_hybrid_mean,
    released_nonhybrid_mean
  )) %>%
    select(branch:ngroups, median, mem_alloc, n_gc)
}

bench_mean(1e6, 10)
bench_mean(1e6, 100000)

bench_mean(1e7, 10)
bench_mean(1e7, 1000000)
