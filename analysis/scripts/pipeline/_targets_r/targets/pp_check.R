# Validation
tar_target(pp_check, brms::pp_check(fit, "dens_overlay", resp = "logv1") + theme_classic())
