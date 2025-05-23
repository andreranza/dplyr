#' Summarise multiple columns
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' Scoped verbs (`_if`, `_at`, `_all`) have been superseded by the use of
#' [pick()] or [across()] in an existing verb. See `vignette("colwise")` for
#' details.
#'
#' The [scoped] variants of [summarise()] make it easy to apply the same
#' transformation to multiple variables.
#' There are three variants.
#'  * `summarise_all()` affects every variable
#'  * `summarise_at()` affects variables selected with a character vector or
#'   vars()
#'  * `summarise_if()` affects variables selected with a predicate function
#'
#' @inheritParams scoped
#' @param .cols This argument has been renamed to `.vars` to fit
#'   dplyr's terminology and is deprecated.
#' @return A data frame. By default, the newly created columns have the shortest
#'   names needed to uniquely identify the output. To force inclusion of a name,
#'   even when not needed, name the input (see examples for details).
#' @seealso [The other scoped verbs][scoped], [vars()]
#'
#' @section Grouping variables:
#'
#' If applied on a grouped tibble, these operations are *not* applied
#' to the grouping variables. The behaviour depends on whether the
#' selection is **implicit** (`all` and `if` selections) or
#' **explicit** (`at` selections).
#'
#' * Grouping variables covered by explicit selections in
#'   `summarise_at()` are always an error. Add `-group_cols()` to the
#'   [vars()] selection to avoid this:
#'
#'   ```
#'   data %>%
#'     summarise_at(vars(-group_cols(), ...), myoperation)
#'   ```
#'
#'   Or remove `group_vars()` from the character vector of column names:
#'
#'   ```
#'   nms <- setdiff(nms, group_vars(data))
#'   data %>% summarise_at(nms, myoperation)
#'   ```
#'
#' * Grouping variables covered by implicit selections are silently
#'   ignored by `summarise_all()` and `summarise_if()`.
#'
#' @section Naming:
#'
#' The names of the new columns are derived from the names of the
#' input variables and the names of the functions.
#'
#' - if there is only one unnamed function (i.e. if `.funs` is an unnamed list
#'   of length one),
#'   the names of the input variables are used to name the new columns;
#'
#' - for `_at` functions, if there is only one unnamed variable (i.e.,
#'   if `.vars` is of the form `vars(a_single_column)`) and `.funs` has length
#'   greater than one,
#'   the names of the functions are used to name the new columns;
#'
#' - otherwise, the new names are created by
#'   concatenating the names of the input variables and the names of the
#'   functions, separated with an underscore `"_"`.
#'
#' The `.funs` argument can be a named or unnamed list.
#' If a function is unnamed and the name cannot be derived automatically,
#' a name of the form "fn#" is used.
#' Similarly, [vars()] accepts named and unnamed arguments.
#' If a variable in `.vars` is named, a new column by that name will be created.
#'
#' Name collisions in the new columns are disambiguated using a unique suffix.
#'
#' @examples
#' # The _at() variants directly support strings:
#' starwars %>%
#'   summarise_at(c("height", "mass"), mean, na.rm = TRUE)
#' # ->
#' starwars %>% summarise(across(c("height", "mass"), ~ mean(.x, na.rm = TRUE)))
#'
#' # You can also supply selection helpers to _at() functions but you have
#' # to quote them with vars():
#' starwars %>%
#'   summarise_at(vars(height:mass), mean, na.rm = TRUE)
#' # ->
#' starwars %>%
#'   summarise(across(height:mass, ~ mean(.x, na.rm = TRUE)))
#'
#' # The _if() variants apply a predicate function (a function that
#' # returns TRUE or FALSE) to determine the relevant subset of
#' # columns. Here we apply mean() to the numeric columns:
#' starwars %>%
#'   summarise_if(is.numeric, mean, na.rm = TRUE)
#' starwars %>%
#'   summarise(across(where(is.numeric), ~ mean(.x, na.rm = TRUE)))
#'
#' by_species <- iris %>%
#'   group_by(Species)
#'
#' # If you want to apply multiple transformations, pass a list of
#' # functions. When there are multiple functions, they create new
#' # variables instead of modifying the variables in place:
#' by_species %>%
#'   summarise_all(list(min, max))
#' # ->
#' by_species %>%
#'   summarise(across(everything(), list(min = min, max = max)))
#' @export
#' @keywords internal
summarise_all <- function(.tbl, .funs, ...) {
  lifecycle::signal_stage("superseded", "summarise_all()")
  funs <- manip_all(
    .tbl,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "summarise_all"
  )
  summarise(.tbl, !!!funs)
}
#' @rdname summarise_all
#' @export
summarise_if <- function(.tbl, .predicate, .funs, ...) {
  lifecycle::signal_stage("superseded", "summarise_if()")
  funs <- manip_if(
    .tbl,
    .predicate,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "summarise_if"
  )
  summarise(.tbl, !!!funs)
}
#' @rdname summarise_all
#' @export
summarise_at <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
  lifecycle::signal_stage("superseded", "summarise_at()")
  .vars <- check_dot_cols(.vars, .cols)
  funs <- manip_at(
    .tbl,
    .vars,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "summarise_at"
  )
  summarise(.tbl, !!!funs)
}

#' @rdname summarise_all
#' @export
summarize_all <- summarise_all
#' @rdname summarise_all
#' @export
summarize_if <- summarise_if
#' @rdname summarise_all
#' @export
summarize_at <- summarise_at

#' Mutate multiple columns
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' Scoped verbs (`_if`, `_at`, `_all`) have been superseded by the use of
#' [pick()] or [across()] in an existing verb. See `vignette("colwise")` for
#' details.
#'
#' The [scoped] variants of [mutate()] and [transmute()] make it easy to apply
#' the same transformation to multiple variables. There are three variants:
#'  * _all affects every variable
#'  * _at affects variables selected with a character vector or vars()
#'  * _if affects variables selected with a predicate function:
#'
#' @inheritParams scoped
#' @inheritParams summarise_all
#' @return A data frame. By default, the newly created columns have the shortest
#'   names needed to uniquely identify the output. To force inclusion of a name,
#'   even when not needed, name the input (see examples for details).
#' @seealso [The other scoped verbs][scoped], [vars()]
#'
#' @section Grouping variables:
#'
#' If applied on a grouped tibble, these operations are *not* applied
#' to the grouping variables. The behaviour depends on whether the
#' selection is **implicit** (`all` and `if` selections) or
#' **explicit** (`at` selections).
#'
#' * Grouping variables covered by explicit selections in
#'   `mutate_at()` and `transmute_at()` are always an error. Add
#'   `-group_cols()` to the [vars()] selection to avoid this:
#'
#'   ```
#'   data %>% mutate_at(vars(-group_cols(), ...), myoperation)
#'   ```
#'
#'   Or remove `group_vars()` from the character vector of column names:
#'
#'   ```
#'   nms <- setdiff(nms, group_vars(data))
#'   data %>% mutate_at(vars, myoperation)
#'   ```
#'
#' * Grouping variables covered by implicit selections are ignored by
#'   `mutate_all()`, `transmute_all()`, `mutate_if()`, and
#'   `transmute_if()`.
#'
#' @inheritSection summarise_all Naming
#'
#' @examples
#' iris <- as_tibble(iris)
#'
#' # All variants can be passed functions and additional arguments,
#' # purrr-style. The _at() variants directly support strings. Here
#' # we'll scale the variables `height` and `mass`:
#' scale2 <- function(x, na.rm = FALSE) (x - mean(x, na.rm = na.rm)) / sd(x, na.rm)
#' starwars %>% mutate_at(c("height", "mass"), scale2)
#' # ->
#' starwars %>% mutate(across(c("height", "mass"), scale2))
#'
#' # You can pass additional arguments to the function:
#' starwars %>% mutate_at(c("height", "mass"), scale2, na.rm = TRUE)
#' starwars %>% mutate_at(c("height", "mass"), ~scale2(., na.rm = TRUE))
#' # ->
#' starwars %>% mutate(across(c("height", "mass"), ~ scale2(.x, na.rm = TRUE)))
#'
#' # You can also supply selection helpers to _at() functions but you have
#' # to quote them with vars():
#' iris %>% mutate_at(vars(matches("Sepal")), log)
#' iris %>% mutate(across(matches("Sepal"), log))
#'
#' # The _if() variants apply a predicate function (a function that
#' # returns TRUE or FALSE) to determine the relevant subset of
#' # columns. Here we divide all the numeric columns by 100:
#' starwars %>% mutate_if(is.numeric, scale2, na.rm = TRUE)
#' starwars %>% mutate(across(where(is.numeric), ~ scale2(.x, na.rm = TRUE)))
#'
#' # mutate_if() is particularly useful for transforming variables from
#' # one type to another
#' iris %>% mutate_if(is.factor, as.character)
#' iris %>% mutate_if(is.double, as.integer)
#' # ->
#' iris %>% mutate(across(where(is.factor), as.character))
#' iris %>% mutate(across(where(is.double), as.integer))
#'
#' # Multiple transformations ----------------------------------------
#'
#' # If you want to apply multiple transformations, pass a list of
#' # functions. When there are multiple functions, they create new
#' # variables instead of modifying the variables in place:
#' iris %>% mutate_if(is.numeric, list(scale2, log))
#' iris %>% mutate_if(is.numeric, list(~scale2(.), ~log(.)))
#' iris %>% mutate_if(is.numeric, list(scale = scale2, log = log))
#' # ->
#' iris %>%
#'   as_tibble() %>%
#'   mutate(across(where(is.numeric), list(scale = scale2, log = log)))
#'
#' # When there's only one function in the list, it modifies existing
#' # variables in place. Give it a name to instead create new variables:
#' iris %>% mutate_if(is.numeric, list(scale2))
#' iris %>% mutate_if(is.numeric, list(scale = scale2))
#' @export
#' @keywords internal
mutate_all <- function(.tbl, .funs, ...) {
  lifecycle::signal_stage("superseded", "mutate_all()")
  check_grouped(.tbl, "mutate", "all", alt = TRUE)
  funs <- manip_all(
    .tbl,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "mutate_all"
  )
  mutate(.tbl, !!!funs)
}
#' @rdname mutate_all
#' @export
mutate_if <- function(.tbl, .predicate, .funs, ...) {
  lifecycle::signal_stage("superseded", "mutate_if()")
  check_grouped(.tbl, "mutate", "if")
  funs <- manip_if(
    .tbl,
    .predicate,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "mutate_if"
  )
  mutate(.tbl, !!!funs)
}
#' @rdname mutate_all
#' @export
mutate_at <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
  lifecycle::signal_stage("superseded", "mutate_at()")
  .vars <- check_dot_cols(.vars, .cols)
  funs <- manip_at(
    .tbl,
    .vars,
    .funs,
    enquo(.funs),
    caller_env(),
    .include_group_vars = TRUE,
    ...,
    .caller = "mutate_at"
  )
  mutate(.tbl, !!!funs)
}

#' @rdname mutate_all
#' @export
transmute_all <- function(.tbl, .funs, ...) {
  lifecycle::signal_stage("superseded", "transmute_all()")
  check_grouped(.tbl, "transmute", "all", alt = TRUE)
  funs <- manip_all(
    .tbl,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "transmute_all"
  )
  transmute(.tbl, !!!funs)
}
#' @rdname mutate_all
#' @export
transmute_if <- function(.tbl, .predicate, .funs, ...) {
  lifecycle::signal_stage("superseded", "transmute_if()")
  check_grouped(.tbl, "transmute", "if")
  funs <- manip_if(
    .tbl,
    .predicate,
    .funs,
    enquo(.funs),
    caller_env(),
    ...,
    .caller = "transmute_if"
  )
  transmute(.tbl, !!!funs)
}
#' @rdname mutate_all
#' @export
transmute_at <- function(.tbl, .vars, .funs, ..., .cols = NULL) {
  lifecycle::signal_stage("superseded", "transmute_at()")
  .vars <- check_dot_cols(.vars, .cols)
  funs <- manip_at(
    .tbl,
    .vars,
    .funs,
    enquo(.funs),
    caller_env(),
    .include_group_vars = TRUE,
    ...,
    .caller = "transmute_at"
  )
  transmute(.tbl, !!!funs)
}

# Helpers -----------------------------------------------------------------

manip_all <- function(
  .tbl,
  .funs,
  .quo,
  .env,
  ...,
  .include_group_vars = FALSE,
  .caller,
  error_call = caller_env()
) {
  if (.include_group_vars) {
    syms <- syms(tbl_vars(.tbl))
  } else {
    syms <- syms(tbl_nongroup_vars(.tbl))
  }
  funs <- as_fun_list(
    .funs,
    .env,
    ...,
    .caller = .caller,
    error_call = error_call,
    .user_env = caller_env(2)
  )
  manip_apply_syms(funs, syms, .tbl)
}
manip_if <- function(
  .tbl,
  .predicate,
  .funs,
  .quo,
  .env,
  ...,
  .include_group_vars = FALSE,
  .caller,
  error_call = caller_env()
) {
  vars <- tbl_if_syms(
    .tbl,
    .predicate,
    .env,
    .include_group_vars = .include_group_vars,
    error_call = error_call
  )
  funs <- as_fun_list(
    .funs,
    .env,
    ...,
    .caller = .caller,
    error_call = error_call,
    .user_env = caller_env(2)
  )
  manip_apply_syms(funs, vars, .tbl)
}
manip_at <- function(
  .tbl,
  .vars,
  .funs,
  .quo,
  .env,
  ...,
  .include_group_vars = FALSE,
  .caller,
  error_call = caller_env()
) {
  syms <- tbl_at_syms(
    .tbl,
    .vars,
    .include_group_vars = .include_group_vars,
    error_call = error_call
  )
  funs <- as_fun_list(
    .funs,
    .env,
    ...,
    .caller = .caller,
    error_call = error_call,
    .user_env = caller_env(2)
  )
  manip_apply_syms(funs, syms, .tbl)
}

check_grouped <- function(tbl, verb, suffix, alt = FALSE) {
  if (is_grouped_df(tbl)) {
    if (alt) {
      alt_line <- sprintf(
        "Use `%s_at(df, vars(-group_cols()), myoperation)` to silence the message.",
        verb
      )
    } else {
      alt_line <- chr()
    }
    inform(c(
      sprintf(
        "`%s_%s()` ignored the following grouping variables:",
        verb,
        suffix
      ),
      set_names(fmt_cols(group_vars(tbl)), "*"),
      "i" = alt_line
    ))
  }
}

check_dot_cols <- function(vars, cols) {
  if (is_null(cols)) {
    vars
  } else {
    inform("`.cols` has been renamed and is deprecated, please use `.vars`")
    if (missing(vars)) cols else vars
  }
}

manip_apply_syms <- function(funs, syms, tbl) {
  out <- vector("list", length(syms) * length(funs))
  dim(out) <- c(length(syms), length(funs))
  syms_position <- match(as.character(syms), tbl_vars(tbl))

  for (i in seq_along(syms)) {
    pos <- syms_position[i]
    for (j in seq_along(funs)) {
      fun <- funs[[j]]
      if (is_quosure(fun)) {
        out[[i, j]] <- expr_substitute(funs[[j]], quote(.), syms[[i]])
      } else {
        out[[i, j]] <- call2(funs[[j]], syms[[i]])
      }
      attr(out[[i, j]], "position") <- pos
    }
  }

  dim(out) <- NULL

  # Use symbols as default names
  unnamed <- !have_name(syms)
  names(syms)[unnamed] <- map_chr(syms[unnamed], as_string)

  if (length(funs) == 1 && !attr(funs, "have_name")) {
    names(out) <- names(syms)
  } else {
    nms <- names(funs) %||% rep("<fn>", length(funs))
    is_fun <- nms == "<fn>" | nms == ""
    nms[is_fun] <- paste0("fn", seq_len(sum(is_fun)))

    nms <- unique_names(nms, quiet = TRUE)
    names(funs) <- nms

    if (length(syms) == 1 && all(unnamed)) {
      names(out) <- names(funs)
    } else {
      syms_names <- ifelse(unnamed, map_chr(syms, as_string), names(syms))
      grid <- expand.grid(var = syms_names, call = names(funs))
      names(out) <- paste(grid$var, grid$call, sep = "_")
    }
  }

  out
}
