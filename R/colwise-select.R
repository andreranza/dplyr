#' Select and rename a selection of variables
#'
#' @description
#' `r lifecycle::badge("superseded")`
#'
#' `rename_if()`, `rename_at()`, and `rename_all()` have been superseded by
#' `rename_with()`. The matching select statements have been superseded by the
#' combination of a `select()` + `rename_with()`. Any predicate functions passed
#' as arguments to `select()` or `rename_with()` must be wrapped in [where()].
#'
#' These functions were superseded because `mutate_if()` and friends were
#' superseded by `across()`. `select_if()` and `rename_if()` already use tidy
#' selection so they can't be replaced by `across()` and instead we need a new
#' function.
#'
#' @inheritParams scoped
#' @keywords internal
#' @param .funs A function `fun`, a purrr style lambda `~ fun(.)` or a list of either form.
#' @examples
#' mtcars <- as_tibble(mtcars) # for nicer printing
#'
#' mtcars %>% rename_all(toupper)
#' # ->
#' mtcars %>% rename_with(toupper)
#'
#' # NB: the transformation comes first in rename_with
#' is_whole <- function(x) all(floor(x) == x)
#' mtcars %>% rename_if(is_whole, toupper)
#' # ->
#' mtcars %>% rename_with(toupper, where(is_whole))
#'
#' mtcars %>% rename_at(vars(mpg:hp), toupper)
#' # ->
#' mtcars %>% rename_with(toupper, mpg:hp)
#'
#' # You now must select() and then rename
#'
#' mtcars %>% select_all(toupper)
#' # ->
#' mtcars %>% rename_with(toupper)
#'
#' # Selection drops unselected variables:
#' mtcars %>% select_if(is_whole, toupper)
#' # ->
#' mtcars %>% select(where(is_whole)) %>% rename_with(toupper)
#'
#' mtcars %>% select_at(vars(-contains("ar"), starts_with("c")), toupper)
#' # ->
#' mtcars %>%
#'   select(!contains("ar") | starts_with("c")) %>%
#'   rename_with(toupper)
#' @export
select_all <- function(.tbl, .funs = list(), ...) {
  lifecycle::signal_stage("superseded", "select_all()")
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "select_all")
  vars <- tbl_vars(.tbl)
  syms <- vars_select_syms(vars, funs, .tbl)
  select(.tbl, !!!syms)
}
#' @rdname select_all
#' @export
rename_all <- function(.tbl, .funs = list(), ...) {
  lifecycle::signal_stage("superseded", "rename_with()")
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "rename_all")
  vars <- tbl_vars(.tbl)
  syms <- vars_select_syms(vars, funs, .tbl, strict = TRUE)
  rename(.tbl, !!!syms)
}

#' @rdname select_all
#' @export
select_if <- function(.tbl, .predicate, .funs = list(), ...) {
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "select_if")
  if (!is_logical(.predicate)) {
    .predicate <- as_fun_list(
      .predicate,
      caller_env(),
      .caller = "select_if",
      .caller_arg = ".predicate"
    )
  }
  vars <- tbl_if_vars(
    .tbl,
    .predicate,
    caller_env(),
    .include_group_vars = TRUE
  )
  syms <- vars_select_syms(vars, funs, .tbl)
  select(.tbl, !!!syms)
}
#' @rdname select_all
#' @export
rename_if <- function(.tbl, .predicate, .funs = list(), ...) {
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "rename_if")
  if (!is_logical(.predicate)) {
    .predicate <- as_fun_list(
      .predicate,
      caller_env(),
      .caller = "rename_if",
      .caller_arg = ".predicate"
    )
  }
  vars <- tbl_if_vars(
    .tbl,
    .predicate,
    caller_env(),
    .include_group_vars = TRUE
  )
  syms <- vars_select_syms(vars, funs, .tbl, strict = TRUE)
  rename(.tbl, !!!syms)
}

#' @rdname select_all
#' @export
select_at <- function(.tbl, .vars, .funs = list(), ...) {
  vars <- tbl_at_vars(.tbl, .vars, .include_group_vars = TRUE)
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "select_at")
  syms <- vars_select_syms(vars, funs, .tbl)
  select(.tbl, !!!syms)
}
#' @rdname select_all
#' @export
rename_at <- function(.tbl, .vars, .funs = list(), ...) {
  vars <- tbl_at_vars(.tbl, .vars, .include_group_vars = TRUE)
  funs <- as_fun_list(.funs, caller_env(), ..., .caller = "rename_at")
  syms <- vars_select_syms(vars, funs, .tbl, strict = TRUE)
  rename(.tbl, !!!syms)
}

vars_select_syms <- function(
  vars,
  funs,
  tbl,
  strict = FALSE,
  error_call = caller_env()
) {
  if (length(funs) > 1) {
    msg <- glue(
      "`.funs` must contain one renaming function, not {length(funs)}."
    )
    abort(msg, call = error_call)
  } else if (length(funs) == 1) {
    fun <- funs[[1]]
    if (is_quosure(fun)) {
      fun <- quo_as_function(fun)
    }
    syms <- if (length(vars)) {
      set_names(syms(vars), fun(as.character(vars)))
    } else {
      set_names(syms(vars))
    }
  } else if (!strict) {
    syms <- syms(vars)
  } else {
    msg <- glue("`.funs` must specify a renaming function.")
    abort(msg, call = error_call)
  }

  group_vars <- group_vars(tbl)
  group_syms <- syms(group_vars)
  has_group_sym <- group_syms %in% syms
  new_group_syms <- set_names(
    group_syms[!has_group_sym],
    group_vars[!has_group_sym]
  )
  c(new_group_syms, syms)
}
