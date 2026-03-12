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
    run_one("Data: no NA in v1", testthat::expect_true(all(!is.na(data$v1)))),
    run_one("Data: required columns (v1, v2, v3, v4, log_v1)", testthat::expect_true(all(c("v1", "v2", "v3", "v4", "log_v1") %in% names(data)))),
    run_one("Data: n > 0", testthat::expect_true(nrow(data) > 0L)),
    run_one("Data: v1 positive", testthat::expect_true(all(data$v1 > 0, na.rm = TRUE))),
    run_one("Data: log_v1 is numeric", testthat::expect_true(is.numeric(data$log_v1))),
    run_one("Model: converged (Rhat < 1.05)", testthat::expect_true(all(brms::rhat(fit) < 1.05, na.rm = TRUE))),
    run_one("Model: has v3 and v4 terms", testthat::expect_true(any(grepl("v3", rownames(brms::fixef(fit)))) && any(grepl("v4", rownames(brms::fixef(fit)))))),
    run_one("Model: has v2 term", testthat::expect_true(any(grepl("v2", rownames(brms::fixef(fit)))))),
    run_one("Model: bivariate (2 responses)", testthat::expect_true(length(fit$formula) >= 2L))
  ) %>%
    dplyr::arrange(passed) %>%
    dplyr::mutate(
      passed_display = dplyr::if_else(passed, "\u2191", "\u2717"),
      passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
    )
}, packages = c("testthat", "tidyverse", "brms"))
