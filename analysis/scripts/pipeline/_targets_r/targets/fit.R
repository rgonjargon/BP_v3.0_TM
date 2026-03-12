tar_target(fit, {
  options(mc.cores = parallel::detectCores())
  # Structural equations: (1) v4 → v3; (2) log_v1 ~ v3 * v4 + v2
  bf_v3 <- brms::bf(v3 ~ v4)
  bf_v1 <- brms::bf(log_v1 ~ v3 * v4 + v2)
  mod_formula <- bf_v3 + bf_v1 + brms::set_rescor(FALSE)
  
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
