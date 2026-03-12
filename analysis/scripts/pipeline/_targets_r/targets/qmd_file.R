# Track 1_targets.qmd so setup_unit_tests invalidates when the report is edited (e.g. title change)
tar_target(qmd_file, {
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  file.path(project_root, "analysis", "scripts", "1_targets.qmd")
}, format = "file")
