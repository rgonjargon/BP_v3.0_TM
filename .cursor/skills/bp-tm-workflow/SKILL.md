---
name: bp-tm-workflow
description: >-
  Runs and debugs the BP v3.0 TM targets pipeline and Quarto report; respects
  repo root _quarto.yml, here(), renv, and analysis/output paths. Use when
  rendering 1_targets.qmd, fixing tar_make() or targets errors, adding pipeline
  targets, editing analysis/scripts/pipeline, or changing setup/bootstrap.
---

# BP v3.0 TM workflow

## Repo layout

- See root `README.md` for folder structure and quick start.
- Conventions are enforced in `.cursor/rules/project-rules.mdc` (always-on) and scoped rules: `quarto-project-root.mdc`, `targets-pipeline.mdc`, `r-renv-cmdstan.mdc`.
- **Report:** `analysis/scripts/1_targets.qmd` (renders to `1_targets_report.html`).
- **Pipeline:** `analysis/scripts/pipeline/` (`_targets.R`, store `_targets/`, generated `_targets_r/`).
- **Outputs:** plots → `analysis/output/plots/`, final tables (one `.xlsx`, one sheet per table) → `analysis/output/tables/`, models → `analysis/output/models/`.

## Quarto

- Render from the **repository root:** `quarto render analysis/scripts/1_targets.qmd`.
- **Do not** add `analysis/scripts/_quarto.yml`. That makes `here::here()` treat `analysis/scripts/` as the project root and breaks targets that use `here("README.md")` at the repo root.
- Bibliography: root `_quarto.yml` points to `analysis/scripts/references.bib`; extend that `.bib` for new citations and keep paths aligned.

## targets

- **Do not** change the logic or expectations of `unit_tests` or `setup_unit_tests` in `1_targets.qmd`. Fix the project so tests pass.
- When editing the report setup chunk, keep: resolve `pipeline_dir`, `knitr::opts_knit$set(root.dir = root_dir)` so chunk execution matches `tar_make()`, and `tar_unscript()` on `_targets.R` so stale `_targets_r/` scripts are cleared.

## renv / CmdStan

- Prefer `renv::restore()` when dependencies change; commit updates to `renv.lock` when the pipeline needs new packages.
- CmdStan: use `CMDSTAN_PATH`, `cmdstanr::set_cmdstan_path()`, or documented environment defaults (see `README.md`). Avoid hard-coded machine-specific paths in committed R scripts.

## Deliverables (reports and outputs)

- Follow `.cursor/rules/project-rules.mdc`: Quarto reports only (`.qmd`); **subtitle** must mention Cursor; figures saved at **600 DPI** under `analysis/output/plots/`; final tables in **one** `.xlsx` under `analysis/output/tables/`; fitted models as `.rds` under `analysis/output/models/`.
