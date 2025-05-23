# Basic behaviour -------------------------------------------------------------

test_that("sample preserves class", {
  expect_s3_class(sample_n(mtcars, 1), "data.frame")
  expect_s3_class(sample_n(as_tibble(mtcars), 1), "tbl_df")

  expect_s3_class(sample_frac(mtcars, 1), "data.frame")
  expect_s3_class(sample_frac(as_tibble(mtcars), 1), "tbl_df")
})

# Ungrouped --------------------------------------------------------------------

test_that("sample respects weight", {
  df <- data.frame(x = 1:2, y = c(0, 1))
  expect_equal(sample_n(df, 1, weight = y)$x, 2)
  expect_equal(sample_frac(df, 0.5, weight = y)$x, 2)
})

test_that("slice does not evaluate the expression in empty groups (#1438)", {
  res <- mtcars %>%
    group_by(cyl) %>%
    filter(cyl == 6) %>%
    slice(1:2)
  expect_equal(nrow(res), 2L)

  expect_error(
    res <- mtcars %>% group_by(cyl) %>% filter(cyl == 6) %>% sample_n(size = 3),
    NA
  )
  expect_equal(nrow(res), 3L)
})

# Grouped ----------------------------------------------------------------------

test_that("sampling grouped tbl samples each group", {
  sampled <- mtcars %>% group_by(cyl) %>% sample_n(2)
  expect_s3_class(sampled, "grouped_df")
  expect_equal(group_vars(sampled), "cyl")
  expect_equal(nrow(sampled), 6)
  expect_equal(map_int(group_rows(sampled), length), c(2, 2, 2))
})

test_that("grouped sample respects weight", {
  df2 <- tibble(
    x = rep(1:2, 100),
    y = rep(c(0, 1), 100),
    g = rep(1:2, each = 100)
  )

  grp <- df2 %>% group_by(g)

  expect_equal(sample_n(grp, 1, weight = y)$x, c(2, 2))
  expect_equal(sample_frac(grp, 0.5, weight = y)$x, rep(2, nrow(df2) / 2))
})

test_that("grouped sample accepts NULL weight from variable (for saeSim)", {
  df <- tibble(
    x = rep(1:2, 10),
    y = rep(c(0, 1), 10),
    g = rep(1:2, each = 10)
  )

  weight <- NULL

  expect_no_error(sample_n(df, nrow(df), weight = weight))
  expect_no_error(sample_frac(df, weight = weight))

  grp <- df %>% group_by(g)

  expect_no_error(sample_n(grp, nrow(df) / 2, weight = weight))
  expect_no_error(sample_frac(grp, weight = weight))
})

test_that("sample_n and sample_frac can call n() (#3413)", {
  df <- tibble(
    x = rep(1:2, 10),
    y = rep(c(0, 1), 10),
    g = rep(1:2, each = 10)
  )
  gdf <- group_by(df, g)

  expect_equal(nrow(sample_n(df, n())), nrow(df))
  expect_equal(nrow(sample_n(gdf, n())), nrow(gdf))

  expect_equal(nrow(sample_n(df, n() - 2L)), nrow(df) - 2)
  expect_equal(nrow(sample_n(gdf, n() - 2L)), nrow(df) - 4)
})

test_that("sample_n and sample_frac handles lazy grouped data frames (#3380)", {
  df1 <- data.frame(x = 1:10, y = rep(1:2, each = 5))
  df2 <- data.frame(x = 6:15, z = 1:10)
  res <- df1 %>% group_by(y) %>% anti_join(df2, by = "x") %>% sample_n(1)
  expect_equal(nrow(res), 1L)

  res <- df1 %>% group_by(y) %>% anti_join(df2, by = "x") %>% sample_frac(0.2)
  expect_equal(nrow(res), 1L)
})

# Errors --------------------------------------------

test_that("sample_*() gives meaningful error messages", {
  expect_snapshot({
    df2 <- tibble(
      x = rep(1:2, 100),
      y = rep(c(0, 1), 100),
      g = rep(1:2, each = 100)
    )

    grp <- df2 %>% group_by(g)

    # base R error messages
    (expect_error(
      sample_n(grp, nrow(df2) / 2, weight = y)
    ))
    (expect_error(
      sample_frac(grp, 1, weight = y)
    ))

    # can't sample more values than obs (without replacement)
    (expect_error(
      mtcars %>% group_by(cyl) %>% sample_n(10)
    ))

    # unknown type
    (expect_error(
      sample_n(list())
    ))
    (expect_error(
      sample_frac(list())
    ))

    "# respects weight"
    df <- data.frame(x = 1:2, y = c(0, 1))
    (expect_error(
      sample_n(df, 2, weight = y)
    ))
    (expect_error(
      sample_frac(df, 2)
    ))
    (expect_error(
      sample_frac(df %>% group_by(y), 2)
    ))
    (expect_error(
      sample_frac(df, 1, weight = y)
    ))
  })
})
