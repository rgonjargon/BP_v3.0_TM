# Install R packages required by the targets pipeline and report.
# Preferred: use renv::restore() to install exact locked versions (see renv.lock).
# This script is a fallback that installs the latest CRAN versions without pinning.
# Run from project root: Rscript analysis/scripts/setup/install_packages.R
# Or from R: source("analysis/scripts/setup/install_packages.R")

repos <- c(CRAN = "https://cloud.r-project.org/")
if (!requireNamespace("here", quietly = TRUE)) {
  utils::install.packages("here", repos = repos, quiet = TRUE)
}

# When renv is active and lockfile exists, restore first so dependencies install from
# the lockfile (preferring binaries from CRAN). This avoids building from source on
# fresh clones, which can fail on macOS when Fortran toolchains differ (e.g. mvtnorm).
if (requireNamespace("renv", quietly = TRUE)) {
  lockfile <- here::here("renv.lock")
  if (file.exists(lockfile)) {
    renv::restore(project = here::here(), prompt = FALSE, repos = repos)
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
  "here",
  "tidyverse", "janitor", "modelr", "tidybayes", "brms",
  "bayesplot", "ggdag", "ggraph", "cmdstanr", "rstan", "targets", "crew", "patchwork", "testthat",
  "writexl", "visNetwork",
  "privacyR",  # used by analysis/data/simulate/anonymize.R (offline, not part of pipeline)
  "readr"
)
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

# CmdStan: this script does not install CmdStan binaries. Set CMDSTAN_PATH to your CmdStan root
# (or rely on the Linux cluster path below when Sys.setenv is used before cmdstanr::set_cmdstan_path).
# Optional: cmdstanr::install_cmdstan() interactively if you need a local toolchain.
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
