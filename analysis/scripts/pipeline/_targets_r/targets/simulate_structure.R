# Structure for simulation: read from analysis/data/simulate/structure.rds.
# Accepts (1) a list with n and columns (type/min/max per column), or (2) a data frame (derived from str(df)-style info: nrow, column types, ranges).
tar_target(simulate_structure, {
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  sim_dir <- file.path(pr, "analysis", "data", "simulate")
  struct_file <- file.path(sim_dir, "structure.rds")
  default <- list(
    n = 153L,
    columns = list(
      v1 = list(type = "numeric", min = 1, max = 168),
      v2 = list(type = "numeric", min = 7, max = 334),
      v3 = list(type = "numeric", min = 2.3, max = 20.7),
      v4 = list(type = "numeric", min = 56, max = 97),
      v5 = list(type = "integer", min = 5L, max = 9L),
      v6 = list(type = "integer", min = 1L, max = 31L)
    )
  )
  if (!file.exists(struct_file)) return(default)
  x <- readRDS(struct_file)
  if (is.data.frame(x)) {
    n <- nrow(x)
    columns <- lapply(x, function(col) {
      if (is.factor(col)) {
        list(type = "factor", levels = as.character(levels(col)))
      } else if (is.integer(col)) {
        r <- range(col, na.rm = TRUE)
        list(type = "integer", min = r[1L], max = r[2L])
      } else if (is.numeric(col)) {
        r <- range(col, na.rm = TRUE)
        list(type = "numeric", min = r[1L], max = r[2L])
      } else {
        list(type = "numeric", min = 0, max = 1)
      }
    })
    names(columns) <- names(x)
    return(list(n = n, columns = columns))
  }
  if (is.list(x) && !is.null(x$columns)) {
    return(list(n = x$n, columns = x$columns))
  }
  default
})
