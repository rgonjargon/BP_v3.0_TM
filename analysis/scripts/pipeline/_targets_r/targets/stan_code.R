# Stan code (v4 → v3; log_v1 ~ v3 * v4 + v2)
tar_target(stan_code, {
  bf_v3 <- brms::bf(v3 ~ v4)
  bf_v1 <- brms::bf(log_v1 ~ v3 * v4 + v2)
  brms::stancode(bf_v3 + bf_v1 + brms::set_rescor(FALSE), data = data, family = list(gaussian(), gaussian()))
})
