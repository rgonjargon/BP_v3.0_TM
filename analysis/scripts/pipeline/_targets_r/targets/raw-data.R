# Raw data: read CSV (rename to v1..v6 using mapping in analysis/data) or simulate from structure (v1..v6)
tar_target(raw_data, {
  path <- raw_data_file$path
  if (isTRUE(raw_data_file$exists)) {
    d <- readr::read_csv(path, show_col_types = FALSE)
    pr <- dirname(dirname(dirname(dirname(path))))
    mapping_path <- file.path(pr, "analysis", "data", "import", "column_mapping.R")
    if (!file.exists(mapping_path)) stop("column_mapping.R not found in analysis/data/import/")
    map_env <- new.env()
    source(mapping_path, local = map_env)
    orig_to_v <- get("orig_to_v", envir = map_env)
    nms <- names(d)
    for (i in seq_along(orig_to_v)) {
      idx <- match(names(orig_to_v)[i], nms)
      if (!is.na(idx)) nms[idx] <- unname(orig_to_v[i])
    }
    names(d) <- nms
    return(d)
  }
  struct <- simulate_structure
  n <- if (!is.null(struct$n)) as.integer(struct$n) else 100L
  cols <- struct$columns
  if (is.null(cols) || length(cols) == 0) {
    stop("No structure to simulate from; add analysis/data/simulate/structure.rds or provide columns in default.")
  }
  out <- lapply(names(cols), function(name) {
    spec <- cols[[name]]
    type <- if (!is.null(spec$type)) spec$type else "numeric"
    if (identical(type, "factor")) {
      levs <- if (!is.null(spec$levels)) spec$levels else character(0)
      if (length(levs) == 0) levs <- NA_character_
      sample(levs, size = n, replace = TRUE)
    } else if (identical(type, "integer")) {
      min_val <- if (!is.null(spec$min)) spec$min else 1L
      max_val <- if (!is.null(spec$max)) spec$max else 31L
      sample(seq(min_val, max_val), size = n, replace = TRUE)
    } else {
      min_val <- if (!is.null(spec$min)) spec$min else 0
      max_val <- if (!is.null(spec$max)) spec$max else 1
      runif(n, min = min_val, max = max_val)
    }
  })
  names(out) <- names(cols)
  tibble::as_tibble(out)
}, packages = "readr")
