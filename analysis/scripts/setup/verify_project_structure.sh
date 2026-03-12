#!/usr/bin/env bash
# Verify all unit tests from 1_targets.qmd:
# - When conditions are met: setup_unit_tests, unit_tests, report_unit_tests all pass.
# - When a required structure item is missing: setup_unit_tests_ok fails.
# After the test the codebase is exactly the same (all .bak restores applied).
# Run from project root: bash analysis/scripts/setup/verify_project_structure.sh
# Requires R, targets, and analysis/data/import/airquality.csv (e.g. run export_airquality_data.R first).

set -e
# Script is at ROOT/analysis/scripts/setup/verify_project_structure.sh
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
PIPELINE="$ROOT/analysis/scripts/pipeline"
cd "$ROOT"

# Restore any .bak left from a previous interrupted run
for x in .cursorignore .gitignore README.md; do [ -e "$ROOT/${x}.bak" ] && mv "$ROOT/${x}.bak" "$ROOT/$x"; done
for r in "$ROOT"/*.Rproj.bak; do [ -e "$r" ] && mv "$r" "${r%.bak}"; done
for d in docs .cursor/rules analysis/data analysis/output analysis/scripts analysis/scripts/setup analysis/scripts/pipeline; do
  [ -d "$ROOT/${d}.bak" ] && mv "$ROOT/${d}.bak" "$ROOT/$d"
done
[ -d "$ROOT/analysis.bak" ] && mv "$ROOT/analysis.bak" "$ROOT/analysis"

# On exit (including interrupt/timeout), restore any .bak so repo is not left broken
restore_baks() {
  set +e
  for x in .cursorignore .gitignore README.md; do [ -e "$ROOT/${x}.bak" ] && mv "$ROOT/${x}.bak" "$ROOT/$x"; done
  for r in "$ROOT"/*.Rproj.bak; do [ -e "$r" ] && mv "$r" "${r%.bak}"; done
  for d in docs .cursor/rules analysis/data analysis/output analysis/scripts analysis/scripts/setup analysis/scripts/pipeline; do
    [ -d "$ROOT/${d}.bak" ] && mv "$ROOT/${d}.bak" "$ROOT/$d"
  done
  [ -d "$ROOT/analysis.bak" ] && mv "$ROOT/analysis.bak" "$ROOT/analysis"
}
trap restore_baks EXIT

run_structure_tests() {
  cd "$PIPELINE" && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1
}

# When we expect failure (item removed): either setup_unit_tests_ok fails or pipeline errors (e.g. missing file target)
# $1 = output from run_structure_tests, $2 = exit code from that run (optional)
check_fail() {
  local out="$1"
  local code="${2:-0}"
  if echo "$out" | grep -q "Setup unit tests failed"; then
    echo "  OK: setup_unit_tests_ok failed as expected."
  elif [ "$code" -ne 0 ] || echo "$out" | grep -qE "errored|Error in tar_make|missing files"; then
    echo "  OK: pipeline failed as expected (missing item caused dependency or unit test failure)."
  else
    echo "  ERROR: expected setup_unit_tests_ok or pipeline to fail when structure item is missing."
    exit 1
  fi
}

# ---- Phase 1: With full structure, all unit tests must pass ----
echo "Phase 1: Running full pipeline and verifying all unit tests pass (setup_unit_tests, unit_tests, report_unit_tests)."
echo ""
cd "$PIPELINE" && Rscript -e "targets::tar_make(reporter = 'verbose')" 2>&1 || { echo "Pipeline failed."; exit 1; }
cd "$ROOT"

cd "$PIPELINE" && Rscript -e '
library(targets)
su <- tar_read(setup_unit_tests)
ut <- tar_read(unit_tests)
ru <- tar_read(report_unit_tests)
if (!all(su$passed)) {
  message("Setup unit tests failed: ", paste(su$test[!su$passed], collapse = "; "))
  quit(status = 1)
}
if (!all(ut$passed)) {
  message("Analysis unit tests failed: ", paste(ut$test[!ut$passed], collapse = "; "))
  quit(status = 1)
}
if (!all(ru$passed)) {
  message("Report unit tests failed: ", paste(ru$test[!ru$passed], collapse = "; "))
  quit(status = 1)
}
message("All unit tests passed.")
' 2>&1 || { echo "Unit test check failed."; exit 1; }
cd "$ROOT"
echo ""

# ---- Phase 2: Removing required items must cause setup_unit_tests_ok to fail ----
echo "Phase 2: Verifying structure enforcement (remove one item -> setup_unit_tests_ok fails -> restore)."
echo ""

# Root files
for f in .cursorignore .gitignore README.md; do
  echo "Test: $f missing"
  [ -e "$f" ] && mv "$f" "$f.bak"
  set +e; out=$(run_structure_tests); r=$?; set -e
  check_fail "$out" "$r"
  [ -e "$f.bak" ] && mv "$f.bak" "$f"
  echo ""
done

# .Rproj
for rproj in "$ROOT"/*.Rproj; do
  [ -e "$rproj" ] || continue
  echo "Test: .Rproj missing"
  mv "$rproj" "${rproj}.bak"
  set +e; out=$(run_structure_tests); r=$?; set -e
  check_fail "$out" "$r"
  mv "${rproj}.bak" "$rproj"
  echo ""
  break
done

# Directories (rename then restore)
for dir in docs .cursor/rules; do
  echo "Test: $dir/ missing"
  [ -d "$dir" ] && mv "$dir" "${dir}.bak"
  set +e; out=$(run_structure_tests); r=$?; set -e
  check_fail "$out" "$r"
  [ -d "${dir}.bak" ] && mv "${dir}.bak" "$dir"
  echo ""
done

for dir in analysis/data analysis/data/import analysis/output analysis/output/models analysis/output/plots analysis/output/tables analysis/scripts/setup; do
  echo "Test: $dir/ missing"
  [ -d "$dir" ] && mv "$dir" "${dir}.bak"
  set +e; out=$(run_structure_tests); r=$?; set -e
  check_fail "$out" "$r"
  [ -d "${dir}.bak" ] && mv "${dir}.bak" "$dir"
  echo ""
done

# analysis/scripts/: pipeline lives inside it
echo "Test: analysis/scripts/ missing"
if [ -d "analysis/scripts" ]; then
  mv analysis/scripts analysis/scripts.bak
  set +e
  out=$(cd "$ROOT/analysis/scripts.bak/pipeline" && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed"; then echo "  OK: setup_unit_tests_ok failed as expected."; elif [ "$r" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  ERROR: expected setup_unit_tests_ok or pipeline to fail when analysis/scripts/ is missing."; exit 1; fi
  mv analysis/scripts.bak analysis/scripts || true
fi
echo ""

# analysis/scripts/pipeline/
echo "Test: analysis/scripts/pipeline/ missing"
if [ -d "analysis/scripts/pipeline" ]; then
  mv analysis/scripts/pipeline analysis/scripts/pipeline.bak
  set +e
  out=$(cd analysis/scripts/pipeline.bak && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed"; then echo "  OK: setup_unit_tests_ok failed as expected."; elif [ "$r" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  ERROR: expected setup_unit_tests_ok or pipeline to fail when analysis/scripts/pipeline/ is missing."; exit 1; fi
  mv analysis/scripts/pipeline.bak analysis/scripts/pipeline || true
fi
echo ""

# analysis/
echo "Test: analysis/ missing"
if [ -d "analysis" ]; then
  mv analysis analysis.bak
  set +e
  out=$(cd analysis.bak/scripts/pipeline && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed\|Error in tar_make\|errored"; then echo "  OK: pipeline failed as expected."; elif [ "${r:-1}" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  ERROR: expected pipeline to fail when analysis/ is missing."; exit 1; fi
  mv analysis.bak analysis || true
fi
echo ""

# Ensure codebase is exactly as before (restore any .bak from phase 2)
restore_baks
echo "Verification complete. All unit tests behave as required; codebase restored."
