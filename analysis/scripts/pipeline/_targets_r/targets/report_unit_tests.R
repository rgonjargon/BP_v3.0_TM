# Report unit tests: setup + analysis summary, Git release readiness, and report/output checks
tar_target(report_unit_tests, {
  pt_setup <- setup_unit_tests
  pt_analysis <- unit_tests
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  git_ok <- pt_setup %>% dplyr::filter(grepl("^Git:", .data$test)) %>% dplyr::pull(.data$passed) %>% all()
  report_path <- file.path(pr, "analysis", "scripts", "1_targets_report.html")
  tables_path <- file.path(pr, "analysis", "output", "tables", "1_targets_report_tables.xlsx")
  plot_dir <- file.path(pr, "analysis", "output", "plots")
  models_dir <- file.path(pr, "analysis", "output", "models")
  report_exists <- file.exists(report_path)
  tables_exported <- file.exists(tables_path)
  key_plots_ok <- file.exists(file.path(plot_dir, "effect_wind_by_temp.png")) &&
    file.exists(file.path(plot_dir, "causal_dag.png"))
  model_saved <- file.exists(file.path(models_dir, "bayesian_fit.rds"))
  dplyr::bind_rows(
    dplyr::tibble(test = "All setup unit tests pass", passed = all(pt_setup$passed)),
    dplyr::tibble(test = "All analysis unit tests pass", passed = all(pt_analysis$passed)),
    dplyr::tibble(test = "Git: release readiness (branch main, clean tree, origin)", passed = git_ok),
    dplyr::tibble(test = "Report output exists", passed = report_exists),
    dplyr::tibble(test = "Tables exported", passed = tables_exported),
    dplyr::tibble(test = "Key outputs present (plots and model)", passed = key_plots_ok && model_saved)
  ) %>%
    dplyr::mutate(
      passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
    )
}, packages = "dplyr")
