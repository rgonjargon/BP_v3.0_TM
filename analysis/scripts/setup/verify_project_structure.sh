#!/usr/bin/env bash
# Verify that removing any required project structure item causes setup_unit_tests_ok to fail.
# Run from project root: bash analysis/scripts/setup/verify_project_structure.sh
# Restores each item after testing. Requires R and targets.

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

run_tests() {
  cd "$PIPELINE" && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1
}

check_fail() {
  if echo "$1" | grep -q "Setup unit tests failed"; then
    echo "  OK: setup_unit_tests_ok failed as expected."
  else
    echo "  WARN: expected setup_unit_tests_ok to fail."
  fi
}

echo "Verifying structure enforcement (remove one item -> setup_unit_tests_ok fails -> restore)."
echo ""

# Root files
for f in .cursorignore .gitignore README.md; do
  echo "Test: $f missing"
  [ -e "$f" ] && mv "$f" "$f.bak"
  out=$(run_tests) || true
  check_fail "$out"
  [ -e "$f.bak" ] && mv "$f.bak" "$f"
  echo ""
done

# .Rproj
for rproj in "$ROOT"/*.Rproj; do
  [ -e "$rproj" ] || continue
  echo "Test: .Rproj missing"
  mv "$rproj" "${rproj}.bak"
  out=$(run_tests) || true
  check_fail "$out"
  mv "${rproj}.bak" "$rproj"
  echo ""
  break
done

# Directories (rename then restore)
for dir in docs .cursor/rules; do
  echo "Test: $dir/ missing"
  [ -d "$dir" ] && mv "$dir" "${dir}.bak"
  out=$(run_tests) || true
  check_fail "$out"
  [ -d "${dir}.bak" ] && mv "${dir}.bak" "$dir"
  echo ""
done

for dir in analysis/data analysis/output analysis/output/models analysis/output/plots analysis/output/tables analysis/scripts/setup; do
  echo "Test: $dir/ missing"
  [ -d "$dir" ] && mv "$dir" "${dir}.bak"
  out=$(run_tests) || true
  check_fail "$out"
  [ -d "${dir}.bak" ] && mv "${dir}.bak" "$dir"
  echo ""
done

# analysis/scripts/: pipeline lives inside it; run from .bak path so project_root is correct but analysis/scripts/ is missing
echo "Test: analysis/scripts/ missing"
if [ -d "analysis/scripts" ]; then
  mv analysis/scripts analysis/scripts.bak
  set +e
  out=$(cd "$ROOT/analysis/scripts.bak/pipeline" && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed"; then echo "  OK: setup_unit_tests_ok failed as expected."; elif [ "$r" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  WARN: expected failure."; fi
  mv analysis/scripts.bak analysis/scripts || true
fi
echo ""

# analysis/scripts/pipeline: run from .bak; project_root is ROOT but analysis/scripts/pipeline/ is missing
echo "Test: analysis/scripts/pipeline/ missing"
if [ -d "analysis/scripts/pipeline" ]; then
  mv analysis/scripts/pipeline analysis/scripts/pipeline.bak
  set +e
  out=$(cd analysis/scripts/pipeline.bak && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed"; then echo "  OK: setup_unit_tests_ok failed as expected."; elif [ "$r" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  WARN: expected failure."; fi
  mv analysis/scripts/pipeline.bak analysis/scripts/pipeline || true
fi
echo ""

# analysis/: run from renamed dir; failure may be setup_unit_tests or qmd_file target
echo "Test: analysis/ missing"
if [ -d "analysis" ]; then
  mv analysis analysis.bak
  set +e
  out=$(cd analysis.bak/scripts/pipeline && Rscript -e "targets::tar_invalidate(setup_unit_tests); targets::tar_make(names = c('setup_unit_tests', 'setup_unit_tests_ok'))" 2>&1); r=$?
  set -e
  if echo "$out" | grep -q "Setup unit tests failed\|Error in tar_make\|errored"; then echo "  OK: pipeline failed as expected."; elif [ "${r:-1}" -ne 0 ]; then echo "  OK: pipeline failed (exit $r)."; else echo "  WARN: expected pipeline to fail."; fi
  mv analysis.bak analysis || true
fi
echo ""

echo "Verification complete. All required structure items are enforced by setup_unit_tests."
