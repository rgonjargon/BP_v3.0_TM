# Wrangling (log-transform ozone for Gaussian model)
tar_target(data, {
  raw_data %>%
    clean_names() %>%
    filter(!is.na(ozone)) %>%
    mutate(log_ozone = log(ozone))
})
