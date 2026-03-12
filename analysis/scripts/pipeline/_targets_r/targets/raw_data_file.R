# Path and existence of airquality.csv in analysis/data/import/. When exists is FALSE, raw_data simulates.
# Encoding existence in the target value ensures the pipeline invalidates when the file is moved or restored.
# Always re-run so that adding/removing the file is picked up (targets does not track non-existent files).
tar_target(raw_data_file, {
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  path <- file.path(pr, "analysis", "data", "import", "airquality.csv")
  list(path = path, exists = file.exists(path))
}, cue = tar_cue(mode = "always"))
