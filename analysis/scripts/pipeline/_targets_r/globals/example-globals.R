# Globals
tar_option_set(format = "rds", 
               controller = crew::crew_controller_local(name = "HAL 9000", workers = 5, seconds_idle = 10),
               memory = "transient",
               garbage_collection = TRUE,
               seed = 42,
               packages = c(
                 "tidyverse", "janitor", "modelr", "tidybayes", "brms",
                 "bayesplot", "ggdag", "cmdstanr", "targets", "patchwork", "testthat"))
