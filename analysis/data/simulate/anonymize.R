# Anonymize airquality data and export its structure for the targets pipeline.
# Uses privacyR for anonymization; applies random transformations to numerics;
# anonymizes factor levels and column headers (v1, v2, ...). Writes
# analysis/data/simulate/structure.rds (list with n, columns, name_mapping)
# readable by the pipeline's simulate_structure target.
#
# Input: airquality.csv from analysis/data/simulate/ (preferred) or analysis/data/import/.
# Run from project root: Rscript analysis/data/simulate/anonymize_export_structure.R
# Or from R: setwd("<project-root>"); source("analysis/data/simulate/anonymize_export_structure.R")
#
# Requires: readr, privacyR (install.packages("privacyR"))

# Project root (from getwd(): setup/, scripts/, simulate/, or project root)
root <- getwd()
if (basename(root) == "setup" && basename(dirname(root)) == "scripts") {
  root <- dirname(dirname(dirname(root)))
}
if (basename(root) == "scripts" && basename(dirname(root)) == "analysis") {
  root <- dirname(dirname(root))
}
if (basename(root) == "simulate" && basename(dirname(root)) == "data") {
  root <- dirname(dirname(dirname(root)))
}

sim_dir <- file.path(root, "analysis", "data", "simulate")
import_dir <- file.path(root, "analysis", "data", "import")
# Prefer airquality.csv in simulate/, then import/
import_path <- file.path(sim_dir, "airquality.csv")
if (!file.exists(import_path)) {
  import_path <- file.path(import_dir, "airquality.csv")
}
if (!file.exists(import_path)) {
  stop("airquality.csv not found in ", sim_dir, " or ", import_dir)
}
dir.create(sim_dir, recursive = TRUE, showWarnings = FALSE)

# Load data
df <- readr::read_csv(import_path, show_col_types = FALSE)

# Optional: add a row identifier so privacyR can anonymize it (preserves referential integrity)
df$row_id <- paste0("R", sprintf("%04d", seq_len(nrow(df))))

# Anonymize row IDs with privacyR (referential integrity; see privacyR vignette)
if (requireNamespace("privacyR", quietly = TRUE)) {
  df$row_id <- privacyR::anonymize_id(df$row_id, seed = 42)
  # Drop the anonymized ID column; pipeline structure does not need it
  df$row_id <- NULL
}

# Convert Month to factor so we can anonymize factor levels
df$Month <- factor(df$Month, levels = 5:9, labels = month.abb[5:9])

# Anonymize factor levels: replace with generic labels (same order, no identifiable names)
anon_factor_levels <- function(x, seed = 42) {
  if (!is.factor(x)) return(x)
  set.seed(seed)
  new_levels <- paste0("L", sample(seq_along(levels(x))))
  levels(x) <- new_levels
  x
}
df$Month <- anon_factor_levels(df$Month, seed = 42)

# Random transformations for numerical variables (scale + jitter for privacy)
set.seed(42)
for (col in c("Ozone", "Solar.R", "Wind", "Temp", "Day")) {
  if (!col %in% names(df)) next
  if (!is.numeric(df[[col]])) next
  # Random linear transform: a * x + b with small noise
  a <- runif(1, 0.9, 1.1)
  b <- rnorm(1, 0, 0.5)
  noise <- rnorm(nrow(df), 0, 0.02 * sd(df[[col]], na.rm = TRUE))
  df[[col]] <- a * df[[col]] + b + noise
  # Keep in reasonable range (no negatives for these vars)
  if (col %in% c("Ozone", "Solar.R", "Wind", "Temp", "Day")) {
    df[[col]] <- pmax(0, df[[col]])
  }
}

# Build structure list (same format the pipeline's simulate_structure expects).
# Anonymise column headers to v1, v2, ... and store name_mapping so the pipeline can restore original names.
structure_from_df <- function(x) {
  n <- nrow(x)
  original_names <- names(x)
  anon_names <- paste0("v", seq_along(original_names))
  columns <- lapply(x, function(col) {
    if (is.factor(col)) {
      list(type = "factor", levels = as.character(levels(col)))
    } else if (is.integer(col)) {
      r <- range(col, na.rm = TRUE)
      list(type = "integer", min = r[1L], max = r[2L])
    } else if (is.numeric(col)) {
      r <- range(col, na.rm = TRUE)
      list(type = "numeric", min = r[1L], max = r[2L])
    } else {
      list(type = "numeric", min = 0, max = 1)
    }
  })
  names(columns) <- anon_names
  name_mapping <- setNames(original_names, anon_names)
  list(n = n, columns = columns, name_mapping = name_mapping)
}

struct <- structure_from_df(df)
out_path <- file.path(sim_dir, "structure.rds")
saveRDS(struct, out_path)
message("Structure written to ", out_path, " (n = ", struct$n, ", ", length(struct$columns), " columns; headers anonymised v1..v", length(struct$columns), ").")
