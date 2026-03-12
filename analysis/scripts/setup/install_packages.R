# Install R packages required by the targets pipeline and report.
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
