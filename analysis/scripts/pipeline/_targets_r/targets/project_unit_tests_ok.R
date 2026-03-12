# Gate: pipeline stops here unless all project unit tests pass
tar_target(project_unit_tests_ok, {
  pt <- project_unit_tests
  if (!all(pt$passed)) {
    failed <- pt$test[!pt$passed]
    stop("Project unit tests failed: ", paste(failed, collapse = "; "))
  }
  invisible(TRUE)
})
