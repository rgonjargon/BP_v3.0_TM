# Bootstrap script: set up the project on a fresh clone.
# Run from project root: Rscript analysis/scripts/setup/bootstrap.R

cat("== Bootstrap: setting up project ==\n")

# 1. Ensure required directories exist
dirs <- c(
  "analysis/data",
  "analysis/data/import",
  "analysis/data/simulate",
  "analysis/output/models",
  "analysis/output/plots",
  "analysis/output/tables",
  "docs"
)
for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
    cat("  Created:", d, "\n")
  }
}

# 2. Install packages (renv preferred, fallback to install_packages.R)
if (file.exists("renv.lock") && requireNamespace("renv", quietly = TRUE)) {
  cat("== Restoring packages from renv.lock ==\n")
  renv::restore(prompt = FALSE)
} else {
  cat("== Installing packages via install_packages.R ==\n")
  source("analysis/scripts/setup/install_packages.R")
}

# 3. Install CmdStan if not present
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  has_cmdstan <- tryCatch(!is.null(cmdstanr::cmdstan_path()), error = function(e) FALSE)
  if (!has_cmdstan) {
    cat("== Installing CmdStan ==\n")
    cmdstanr::install_cmdstan(quiet = TRUE)
  } else {
    cat("== CmdStan already installed ==\n")
  }
}

# 4. Destroy stale targets store (meta from another machine won't work)
pipeline_dir <- "analysis/scripts/pipeline"
if (dir.exists(file.path(pipeline_dir, "_targets"))) {
  cat("== Clearing stale targets store ==\n")
  old_wd <- setwd(pipeline_dir)
  targets::tar_destroy(ask = FALSE)
  setwd(old_wd)
}

cat("== Bootstrap complete. Run: quarto render analysis/scripts/1_targets.qmd ==\n")
