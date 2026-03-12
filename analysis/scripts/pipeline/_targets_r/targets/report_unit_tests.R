# Report unit tests: setup + analysis summary, Git release readiness, and report/output checks
tar_target(report_unit_tests, {
  pt_setup <- setup_unit_tests
  pt_analysis <- unit_tests
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  git_ok <- pt_setup %>% dplyr::filter(grepl("^Git:", .data$test)) %>% dplyr::pull(.data$passed) %>% all()
  report_path <- file.path(pr, "analysis", "scripts", "1_targets_report.html")
  plot_dir <- file.path(pr, "analysis", "output", "plots")
  models_dir <- file.path(pr, "analysis", "output", "models")
  report_exists <- file.exists(report_path)
  key_plots_ok <- all(file.exists(file.path(plot_dir, c(
    "effect_wind_by_temp.png", "effect_wind_by_solar_r.png", "causal_dag.png",
    "pp_check.png", "ozone_vs_wind_raw.png", "ozone_vs_temp_raw.png", "ozone_vs_solar_r_raw.png"
  ))))
  model_saved <- file.exists(file.path(models_dir, "bayesian_fit.rds"))
  dplyr::bind_rows(
    dplyr::tibble(test = "All setup unit tests pass", passed = all(pt_setup$passed)),
    dplyr::tibble(test = "All analysis unit tests pass", passed = all(pt_analysis$passed)),
    dplyr::tibble(test = "Git: release readiness (branch main, clean tree, origin)", passed = git_ok),
    dplyr::tibble(test = "Report output exists", passed = report_exists),
    dplyr::tibble(test = "Key outputs present (plots and model)", passed = key_plots_ok && model_saved)
  ) %>%
    dplyr::mutate(
      passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
    )
}, packages = "dplyr")
