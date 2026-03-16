# Install R packages required by the targets pipeline and report.
# Preferred: use renv::restore() to install exact locked versions (see renv.lock).
# This script is a fallback that installs the latest CRAN versions without pinning.
# Run from project root: Rscript analysis/scripts/setup/install_packages.R
# Or from R: source("analysis/scripts/setup/install_packages.R")

# When renv is active and lockfile exists, restore first so dependencies install from
# the lockfile (preferring binaries from CRAN). This avoids building from source on
# fresh clones, which can fail on macOS when Fortran toolchains differ (e.g. mvtnorm).
if (requireNamespace("renv", quietly = TRUE)) {
  project_root <- tryCatch(renv::project(), error = function(e) getwd())
  if (length(project_root) != 1L || !nzchar(project_root)) {
    project_root <- getwd()
  }
  lockfile <- file.path(project_root, "renv.lock")
  if (file.exists(lockfile)) {
    renv::restore(project = project_root, prompt = FALSE, repos = c(CRAN = "https://cloud.r-project.org"))
  }
  # On macOS, mvtnorm often fails to build from source (Fortran linker). Install from binary
  # so later installs (e.g. brms deps) do not trigger a source build.
  if (Sys.info()["sysname"] == "Darwin" && !requireNamespace("mvtnorm", quietly = TRUE)) {
    tryCatch(
      utils::install.packages("mvtnorm", type = "binary", repos = "https://cloud.r-project.org", lib = .libPaths()[1L], quiet = TRUE),
      error = function(e) NULL
    )
  }
}

pkgs <- c(
  "tidyverse", "janitor", "modelr", "tidybayes", "brms",
  "bayesplot", "ggdag", "ggraph", "cmdstanr", "rstan", "targets", "crew", "patchwork", "testthat",
  "writexl", "visNetwork",
  "privacyR",  # used by analysis/data/simulate/anonymize.R (offline, not part of pipeline)
  "readr"
)
repos <- c(CRAN = "https://cloud.r-project.org/")
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    if (requireNamespace("renv", quietly = TRUE) && !is.null(renv::project())) {
      # Install to project library; renv shim can say "not available" for packages not in lockfile
      utils::install.packages(p, repos = repos, lib = .libPaths()[1L], quiet = TRUE)
    } else {
      install.packages(p, repos = repos)
    }
  }
}

# CmdStan: on Linux (cluster) use known path if it exists; else CMDSTAN_PATH if set; otherwise install if not present.
cluster_cmdstan <- "/powerplant/workspace/hrltxm/workbench-k8s/stan/mod_stan/cmdstan-2.36.0"
if (Sys.info()["sysname"] == "Linux" && dir.exists(cluster_cmdstan) && !nzchar(Sys.getenv("CMDSTAN_PATH"))) {
  Sys.setenv(CMDSTAN_PATH = cluster_cmdstan)
}
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  if (nzchar(Sys.getenv("CMDSTAN_PATH"))) {
    cmdstanr::set_cmdstan_path(Sys.getenv("CMDSTAN_PATH"))
  } else if (!nzchar(Sys.getenv("CMDSTAN")) &&
      tryCatch(is.null(cmdstanr::cmdstan_path()), error = function(e) TRUE)) {
    message("Installing CmdStan (one-time setup, may take a few minutes)...")
    cmdstanr::install_cmdstan(quiet = TRUE)
  }
}
