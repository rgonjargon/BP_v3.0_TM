# Data source mode: use_import when airquality.csv exists, use_anonymised when pipeline simulates (e.g. from structure.rds).
tar_target(data_source, {
  list(use_import = raw_data_file$exists, use_anonymised = !raw_data_file$exists)
})
