# Setup unit tests: compliance with project rules (structure, Cursor, Quarto, git, config)
tar_target(setup_unit_tests, {
  library(testthat)
  library(tibble)
  run_one <- function(name, expr) {
    tryCatch(
      { force(expr); tibble(test = name, passed = TRUE) },
      error = function(e) tibble(test = name, passed = FALSE)
    )
  }
  pr <- if (basename(getwd()) == "pipeline") dirname(dirname(dirname(getwd()))) else getwd()
  if (basename(getwd()) == "scripts" && basename(dirname(getwd())) == "analysis") pr <- dirname(dirname(getwd()))
  qmd_path <- qmd_file
  readme_path <- readme_file
  project_rules_path <- project_rules_file
  install_packages_path <- install_packages_file
  p <- function(...) file.path(pr, ...)
  read_txt <- function(path) paste(readLines(path, warn = FALSE), collapse = " ")

  dirs <- setNames(c("analysis", "analysis/data", "analysis/data/import", "analysis/output", "analysis/output/models", "analysis/output/plots", "analysis/output/tables", "analysis/scripts", "analysis/scripts/pipeline", "analysis/scripts/setup", "docs", ".cursor/rules"),
    c("Directory: analysis/", "Directory: analysis/data/", "Directory: analysis/data/import/", "Directory: analysis/output/", "Directory: analysis/output/models/", "Directory: analysis/output/plots/", "Directory: analysis/output/tables/", "Directory: analysis/scripts/", "Directory: analysis/scripts/pipeline/", "Directory: analysis/scripts/setup/", "Directory: docs/", "Directory: .cursor/rules"))
  dir_tests <- lapply(seq_along(dirs), function(i) run_one(paste0(names(dirs)[i], " exists"), testthat::expect_true(dir.exists(p(dirs[i])))))

  files <- setNames(c(".cursorignore", ".gitignore", "README.md"), c("File: .cursorignore", "File: .gitignore", "File: README.md"))
  file_tests <- lapply(seq_along(files), function(i) run_one(paste0(names(files)[i], " at root"), testthat::expect_true(file.exists(p(files[i])))))
  rproj_test <- list(run_one("File: .Rproj at root", testthat::expect_true(length(list.files(pr, pattern = "\\.Rproj$")) >= 1L)))

  qmd <- if (file.exists(qmd_path)) read_txt(qmd_path) else ""
  git <- function(...) tryCatch(system2("git", c(...), stdout = TRUE, stderr = FALSE), error = function(e) character(0))
  gi <- if (file.exists(p(".gitignore"))) read_txt(p(".gitignore")) else ""
  ci <- if (file.exists(p(".cursorignore"))) read_txt(p(".cursorignore")) else ""

  report_tests <- list(
    run_one("Cursor transparency: subtitle mentions Cursor", testthat::expect_true(grepl("subtitle:.*[Cc]ursor", qmd))),
    run_one("Quarto: title not default", testthat::expect_false(grepl('title:\\s*["\']New Document["\']', qmd))),
    run_one("Quarto: .qmd in analysis/scripts/", testthat::expect_true(length(list.files(p("analysis", "scripts"), pattern = "\\.qmd$")) >= 1L)),
    run_one("Quarto only: no .Rmd in analysis/scripts/", testthat::expect_true(length(list.files(p("analysis", "scripts"), pattern = "\\.Rmd$")) == 0L))
  )
  git_tests <- list(
    run_one("Git: is repository", testthat::expect_true(dir.exists(p(".git")) || identical(git("rev-parse", "--is-inside-work-tree"), "true"))),
    run_one("Git: branch is main", testthat::expect_true(git("branch", "--show-current") %in% c("main", "master"))),
    run_one("Git: remote origin", testthat::expect_true("origin" %in% git("remote", "show")))
  )
  config_tests <- list(
    run_one("README: mentions pipeline/run", testthat::expect_true(grepl("pipeline|quarto|run|quick start", read_txt(readme_path), ignore.case = TRUE))),
    run_one("Project rules: project-rules.mdc", {
      testthat::expect_true(file.exists(project_rules_path))
      testthat::expect_true(grepl("Quarto|analysis|Cursor", read_txt(project_rules_path)))
    }),
    run_one("Output writable: analysis/output/plots", {
      tf <- p("analysis", "output", "plots", ".proj_test"); dir.create(dirname(tf), recursive = TRUE, showWarnings = FALSE)
      writeLines("x", tf); on.exit(unlink(tf, force = TRUE), add = TRUE)
      testthat::expect_true(file.exists(tf)); unlink(tf, force = TRUE)
    }),
    run_one("No top-level scripts/ (per rules)", testthat::expect_false(dir.exists(p("scripts")))),
    run_one(".cursorignore: excludes _targets or output", testthat::expect_true(grepl("_targets|output", ci))),
    run_one("Output writable: analysis/output/tables", {
      tf <- p("analysis", "output", "tables", ".proj_test"); dir.create(dirname(tf), recursive = TRUE, showWarnings = FALSE)
      writeLines("x", tf); on.exit(unlink(tf, force = TRUE), add = TRUE)
      testthat::expect_true(file.exists(tf)); unlink(tf, force = TRUE)
    }),
    run_one("Report YAML: has output-file", testthat::expect_true(grepl("output-file|output_file", qmd))),
    run_one("R version >= 4.0", testthat::expect_true(getRversion() >= "4.0.0"))
  )

  # Pipeline packages (must match tar_option_set(packages = ...) in globals)
  pipeline_packages <- c(
    "tidyverse", "janitor", "modelr", "tidybayes", "brms",
    "bayesplot", "ggdag", "cmdstanr", "targets", "patchwork", "testthat"
  )
  package_tests <- lapply(pipeline_packages, function(pkg) {
    run_one(paste0("Package: ", pkg), {
      ok <- suppressPackageStartupMessages(suppressWarnings(require(pkg, character.only = TRUE, quietly = TRUE)))
      testthat::expect_true(ok)
    })
  })

  software_tests <- list(
    run_one("Software: R available", testthat::expect_true(nzchar(R.version.string))),
    run_one("Software: Quarto (quarto --version)", {
      code <- tryCatch(system2("quarto", "--version", stdout = FALSE, stderr = FALSE), error = function(e) 1L)
      testthat::expect_true(code == 0L)
    })
  )

  out <- dplyr::bind_rows(c(dir_tests, file_tests, rproj_test, report_tests, git_tests, config_tests, package_tests, software_tests))
  out %>% dplyr::arrange(passed) %>%
    dplyr::mutate(
      passed_display = dplyr::if_else(passed, "\u2191", "\u2717"),
      passed_html = dplyr::if_else(passed, '<span style="color:#16a34a">\u2191</span>', '<span style="color:#dc2626">\u2717</span>')
    )
}, packages = c("testthat", "tidyverse"))
