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

# 3. CmdStan: on Linux (cluster) use known path if it exists; else CMDSTAN_PATH if set; otherwise install if not present
cluster_cmdstan <- "/powerplant/workspace/hrltxm/workbench-k8s/stan/mod_stan/cmdstan-2.36.0"
if (Sys.info()["sysname"] == "Linux" && dir.exists(cluster_cmdstan) && !nzchar(Sys.getenv("CMDSTAN_PATH"))) {
  Sys.setenv(CMDSTAN_PATH = cluster_cmdstan)
}
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  if (nzchar(Sys.getenv("CMDSTAN_PATH"))) {
    cmdstanr::set_cmdstan_path(Sys.getenv("CMDSTAN_PATH"))
    cat("== Using CmdStan at CMDSTAN_PATH ==\n")
  } else {
    has_cmdstan <- tryCatch(!is.null(cmdstanr::cmdstan_path()), error = function(e) FALSE)
    if (!has_cmdstan) {
      cat("== Installing CmdStan ==\n")
      cmdstanr::install_cmdstan(quiet = TRUE)
    } else {
      cat("== CmdStan already installed ==\n")
    }
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
