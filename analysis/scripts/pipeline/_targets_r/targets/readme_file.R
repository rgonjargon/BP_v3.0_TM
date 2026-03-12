# Track README.md so setup_unit_tests invalidates when README is edited
tar_target(readme_file, {
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") project_root <- dirname(dirname(getwd()))
  file.path(project_root, "README.md")
}, format = "file")
