# Track README.md so setup_unit_tests invalidates when README is edited
tar_target(readme_file, {
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  file.path(project_root, "README.md")
}, format = "file")
