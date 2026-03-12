# Path and existence of airquality.csv in analysis/data/import/. When exists is FALSE, raw_data simulates.
# Encoding existence in the target value ensures downstream targets (e.g. raw_data) use the right branch.
# If you add or remove airquality.csv in import/, run targets::tar_invalidate(raw_data_file) then tar_make() to refresh.
tar_target(raw_data_file, {
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  path <- file.path(pr, "analysis", "data", "import", "airquality.csv")
  list(path = path, exists = file.exists(path))
})
