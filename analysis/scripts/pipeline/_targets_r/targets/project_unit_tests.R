# Project unit tests: check compliance with project rules (directory structure, Cursor transparency, Quarto, outputs)
tar_target(project_unit_tests, {
  library(testthat)
  library(tibble)
  run_one <- function(test_name, expr) {
    out <- tryCatch(
      { force(expr); tibble(test = test_name, passed = TRUE) },
      error = function(e) tibble(test = test_name, passed = FALSE)
    )
    out
  }
  # Project root and qmd path (qmd_file dependency ensures we re-run when 1_targets.qmd changes)
  project_root <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  qmd_path <- qmd_file
  # Directory structure checks (must match .cursor/rules/project-rules.mdc)
  out <- dplyr::bind_rows(
    run_one("Directory: analysis/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis")))),
    run_one("Directory: analysis/data/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "data")))),
    run_one("Directory: analysis/output/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "output")))),
    run_one("Directory: analysis/output/models/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "output", "models")))),
    run_one("Directory: analysis/output/plots/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "output", "plots")))),
    run_one("Directory: analysis/output/tables/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "output", "tables")))),
    run_one("Directory: analysis/scripts/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "scripts")))),
    run_one("Directory: analysis/scripts/pipeline/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "scripts", "pipeline")))),
    run_one("Directory: analysis/scripts/setup/ exists", testthat::expect_true(dir.exists(file.path(project_root, "analysis", "scripts", "setup")))),
    run_one("Directory: docs/ exists", testthat::expect_true(dir.exists(file.path(project_root, "docs")))),
    run_one("Directory: .cursor/rules exists", testthat::expect_true(dir.exists(file.path(project_root, ".cursor", "rules")))),
    run_one("File: .cursorignore exists at root", testthat::expect_true(file.exists(file.path(project_root, ".cursorignore")))),
    run_one("File: .gitignore exists at root", testthat::expect_true(file.exists(file.path(project_root, ".gitignore")))),
    run_one("File: README.md exists at root", testthat::expect_true(file.exists(file.path(project_root, "README.md")))),
    run_one("File: .Rproj exists at root", testthat::expect_true(length(list.files(project_root, pattern = "\\.Rproj$", full.names = FALSE)) >= 1L)),
    run_one("Cursor transparency: report subtitle mentions Cursor", {
      testthat::expect_true(file.exists(qmd_path))
      qmd <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
      testthat::expect_true(grepl("subtitle:.*[Cc]ursor", qmd))
    }),
    run_one("Quarto title changed from default (New Document)", {
      testthat::expect_true(file.exists(qmd_path))
      qmd <- paste(readLines(qmd_path, warn = FALSE), collapse = "\n")
      testthat::expect_false(grepl('title:\\s*["\']New Document["\']', qmd))
    }),
    run_one("Reports: Quarto .qmd present in analysis/scripts/", testthat::expect_true(length(list.files(file.path(project_root, "analysis", "scripts"), pattern = "\\.qmd$", full.names = FALSE)) >= 1L))
  )
  # Failed tests first, then passed; then display columns
  out %>% dplyr::arrange(passed) %>%
  dplyr::mutate(
    passed_display = dplyr::if_else(passed, "\u2191", "\u2717"),
    passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
  )
}, packages = c("testthat", "tidyverse"))
