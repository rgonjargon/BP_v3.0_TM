# Gate: pipeline stops here unless all setup unit tests pass
tar_target(setup_unit_tests_ok, {
  pt <- setup_unit_tests
  if (!all(pt$passed)) {
    failed <- pt$test[!pt$passed]
    stop("Setup unit tests failed: ", paste(failed, collapse = "; "))
  }
  invisible(TRUE)
})
