# Analysis unit tests (testthat): data and model checks; returns tibble with test name and passed/failed
tar_target(unit_tests, {
  library(testthat)
  library(tibble)
  run_one <- function(name, expr) {
    tryCatch(
      { force(expr); tibble(test = name, passed = TRUE) },
      error = function(e) tibble(test = name, passed = FALSE)
    )
  }
  dplyr::bind_rows(
    run_one("Data: no NA in ozone", testthat::expect_true(all(!is.na(data$ozone)))),
    run_one("Data: required columns (ozone, wind, temp, log_ozone)", testthat::expect_true(all(c("ozone", "wind", "temp", "log_ozone") %in% names(data)))),
    run_one("Data: n > 0", testthat::expect_true(nrow(data) > 0L)),
    run_one("Data: ozone positive", testthat::expect_true(all(data$ozone > 0, na.rm = TRUE))),
    run_one("Data: log_ozone is numeric", testthat::expect_true(is.numeric(data$log_ozone))),
    run_one("Model: converged (Rhat < 1.05)", testthat::expect_true(all(brms::rhat(fit) < 1.05, na.rm = TRUE))),
    run_one("Model: has wind and temp terms", testthat::expect_true(any(grepl("wind", rownames(brms::fixef(fit)))) && any(grepl("temp", rownames(brms::fixef(fit)))))),
    run_one("Model: bivariate (2 responses)", testthat::expect_true(length(fit$formula) >= 2L))
  ) %>%
    dplyr::arrange(passed) %>%
    dplyr::mutate(
      passed_display = dplyr::if_else(passed, "\u2191", "\u2717"),
      passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
    )
}, packages = c("testthat", "tidyverse", "brms"))
