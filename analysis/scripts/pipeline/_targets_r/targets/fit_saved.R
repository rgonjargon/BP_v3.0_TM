# Save Bayesian fit to analysis/output/models (per project rules); runs after fit so file is always written
tar_target(fit_saved, {
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  models_dir <- file.path(pr, "analysis", "output", "models")
  dir.create(models_dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(models_dir, "bayesian_fit.rds")
  saveRDS(fit, path)
  path
}, format = "file")
