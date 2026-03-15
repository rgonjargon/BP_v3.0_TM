source("renv/activate.R")
# Auto-restore lockfile packages when missing (e.g. fresh clone), so rendering works without a manual restore
if (requireNamespace("renv", quietly = TRUE) && file.exists("renv.lock")) {
  tryCatch({
    s <- renv::status()
    if (is.list(s) && identical(s$synchronized, FALSE)) {
      renv::restore(prompt = FALSE)
    }
  }, error = function(e) NULL)
}
