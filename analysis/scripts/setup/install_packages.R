# Install R packages required by the targets pipeline and report.
# Preferred: use renv::restore() to install exact locked versions (see renv.lock).
# This script is a fallback that installs the latest CRAN versions without pinning.
# Run from project root: Rscript analysis/scripts/setup/install_packages.R
# Or from R: source("analysis/scripts/setup/install_packages.R")

pkgs <- c(
  "tidyverse", "janitor", "modelr", "tidybayes", "brms",
  "bayesplot", "ggdag", "cmdstanr", "targets", "crew", "patchwork", "testthat",
  "writexl", "visNetwork",
  "privacyR",  # used by analysis/data/simulate/anonymize.R (offline, not part of pipeline)
  "readr"
)
for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org/")
  }
}

# CmdStan: use CMDSTAN_PATH if set; otherwise install if not present.
if (requireNamespace("cmdstanr", quietly = TRUE)) {
  if (nzchar(Sys.getenv("CMDSTAN_PATH"))) {
    cmdstanr::set_cmdstan_path(Sys.getenv("CMDSTAN_PATH"))
  } else if (!nzchar(Sys.getenv("CMDSTAN")) &&
      tryCatch(is.null(cmdstanr::cmdstan_path()), error = function(e) TRUE)) {
    message("Installing CmdStan (one-time setup, may take a few minutes)...")
    cmdstanr::install_cmdstan(quiet = TRUE)
  }
}
