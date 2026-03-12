# Wrangling: log-transform v1; keep complete cases on v1, v2
tar_target(data, {
  raw_data %>%
    filter(!is.na(v1), !is.na(v2)) %>%
    mutate(log_v1 = log(v1))
})
