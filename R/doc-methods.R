# Adapted from sloop
methods_generic <- function(x) {
  # Return early if generic not defined in global environment. This happens
  # when the documentation is read before the package is attached, or when
  # previewing development documentation from RStudio, since it renders the
  # files in a separate session.
  if (!"package:dplyr" %in% search()) {
    return(data.frame())
  }

  info <- eval(expr(attr(utils::methods(!!x), "info")), envir = globalenv())
  info <- tibble::as_tibble(info, rownames = "method")

  generic_esc <- gsub("([.\\[])", "\\\\\\1", x)
  info$class <- gsub(paste0("^", generic_esc, "[.,]"), "", info$method)
  info$class <- gsub("-method$", "", info$class)
  info$source <- gsub(paste0(" for ", generic_esc), "", info$from)

  # Find package
  methods <- map2(
    info$generic,
    info$class,
    utils::getS3method,
    optional = TRUE,
    envir = globalenv()
  )
  envs <- map(methods, environment)
  info$package <- map_chr(envs, environmentName)

  # Find help topic, if it exists
  info$topic <- help_topic(info$method, info$package)
  # Don't link to self
  info$topic[info$topic == x] <- NA

  # Remove spurious matches in base packages like select.list or slice.index
  base_packages <- c(
    "base",
    "compiler",
    "datasets",
    "graphics",
    "grDevices",
    "grid",
    "methods",
    "parallel",
    "splines",
    "stats",
    "stats4",
    "tcltk",
    "tools",
    "utils"
  )
  info <- info[!info$package %in% base_packages, ]

  info[c("generic", "class", "package", "topic", "visible", "source", "isS4")]
}

methods_rd <- function(x) {
  methods <- tryCatch(methods_generic(x), error = function(e) data.frame())
  if (nrow(methods) == 0) {
    return("no methods found")
  }

  methods <- methods[order(methods$package, methods$class), , drop = FALSE]
  topics <- unname(split(methods, methods$package))
  by_package <- vapply(
    topics,
    function(x) {
      links <- topic_links(x$class, x$package, x$topic)
      paste0(x$package[[1]], " (", paste0(links, collapse = ", "), ")")
    },
    character(1)
  )

  paste0(by_package, collapse = ", ")
}

topic_links <- function(class, package, topic) {
  ifelse(
    is.na(topic),
    paste0("\\code{", class, "}"),
    paste0("\\code{\\link[", package, ":", topic, "]{", class, "}}")
  )
}

help_topic <- function(x, pkg) {
  find_one <- function(topic, pkg) {
    if (identical(pkg, "")) {
      return(NA_character_)
    }

    path <- system.file("help", "aliases.rds", package = pkg)
    if (!file.exists(path)) {
      return(NA_character_)
    }

    aliases <- readRDS(path)
    if (!topic %in% names(aliases)) {
      return(NA_character_)
    }
    aliases[[topic]]
  }

  map2_chr(x, pkg, find_one)
}
