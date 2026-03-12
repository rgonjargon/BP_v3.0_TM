tar_target(eff_wind_by_solar_r, {
  cond <- data.frame(v2 = quantile(data$v2, probs = c(0.25, 0.75)), v4 = mean(data$v4))
  v2_vals <- round(cond$v2, 1)
  ce <- conditional_effects(fit, effects = "v3", conditions = cond, re_formula = NA)
  dfs <- ce[sapply(ce, is.data.frame)]
  c_eff <- if (length(dfs) >= 2L) dfs[[2L]] else dfs[[1L]]
  c_eff <- c_eff %>% mutate(across(c(estimate__, lower__, upper__), exp))
  ggplot(c_eff, aes(x = effect1__, y = estimate__, ymin = lower__, ymax = upper__,
                    fill = cond__, color = cond__)) +
    theme_classic() +
    theme(legend.position = "bottom") +
    geom_ribbon(alpha = 0.3, colour = NA) +
    geom_line(linewidth = 1.5) +
    scale_fill_manual(values = c("#CC6677", "#44AA99"), name = "v2") +
    scale_color_manual(values = c("#CC6677", "#44AA99"), name = "v2") +
    labs(
      title = "Effect of v3 on v1",
      subtitle = paste0("v2 held at 25th and 75th percentiles (", paste(v2_vals, collapse = " and "), ")"),
      y = "v1", x = "v3"
    )
})
