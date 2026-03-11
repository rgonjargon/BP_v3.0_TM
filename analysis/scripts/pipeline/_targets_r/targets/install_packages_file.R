# Track install_packages.R so setup_unit_tests invalidates when package list changes
tar_target(install_packages_file, {
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  file.path(project_root, "analysis", "scripts", "setup", "install_packages.R")
}, format = "file")
