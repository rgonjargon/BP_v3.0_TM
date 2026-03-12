tar_target(eff_wind_by_temp, {
  cond <- data.frame(v4 = quantile(data$v4, probs = c(0.25, 0.75)), v2 = mean(data$v2))
  v4_vals <- round(cond$v4, 1)
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
    scale_fill_manual(values = c("#882255", "#6699CC"), name = "v4") +
    scale_color_manual(values = c("#882255", "#6699CC"), name = "v4") +
    labs(
      title = "Effect of v3 on v1",
      subtitle = paste0("v4 held at 25th and 75th percentiles (", paste(v4_vals, collapse = " and "), ")"),
      y = "v1", x = "v3"
    )
})
