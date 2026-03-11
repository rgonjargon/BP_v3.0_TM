tar_target(fit, {
  # Set up parallel processing
  options(mc.cores = parallel::detectCores())
  
  # Structural equations: (1) temperature → wind; (2) wind + temperature → log_ozone
  bf_wind <- brms::bf(wind ~ temp)
  bf_ozone <- brms::bf(log_ozone ~ wind * temp)
  mod_formula <- bf_wind + bf_ozone + brms::set_rescor(FALSE)
  
  priors <- c(brms::prior(normal(0, 1), class = Intercept),
              brms::prior(normal(0, 1), class = b),
              brms::prior(normal(0, 1), class = sigma))
  
  tryCatch({
    brms::brm(mod_formula, family = list(gaussian(), gaussian()),
        data = data,
        threads = brms::threading(threads = NULL, grainsize = 1250, static = FALSE),
        backend = "cmdstanr", silent = 0, refresh = 100,
        chains = 4, cores = 4, warmup = 1000, iter = 2000, seed = 42)
  }, error = function(e) {
    brms::brm(mod_formula, family = list(gaussian(), gaussian()),
        data = data,
        backend = "rstan", silent = 0, refresh = 100,
        chains = 4, cores = 4, warmup = 1000, iter = 2000, seed = 42)
  })
})
