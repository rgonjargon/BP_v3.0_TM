# Stan code (structural equations: temp → wind; wind + temp → log_ozone)
tar_target(stan_code, {
  bf_wind <- brms::bf(wind ~ temp)
  bf_ozone <- brms::bf(log_ozone ~ wind * temp)
  brms::stancode(bf_wind + bf_ozone + brms::set_rescor(FALSE), data = data, family = list(gaussian(), gaussian()))
})
