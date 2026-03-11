# Summary
tar_target(data_summary, data %>% summarise(across(everything(), mean)))
