# Validation
tar_target(pp_check, brms::pp_check(fit, "dens_overlay", resp = "logozone") + theme_classic())
