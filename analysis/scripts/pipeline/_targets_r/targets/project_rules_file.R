# Track project rules so setup_unit_tests invalidates when rules are edited
tar_target(project_rules_file, {
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") project_root <- dirname(dirname(getwd()))
  file.path(project_root, ".cursor", "rules", "project-rules.mdc")
}, format = "file")
