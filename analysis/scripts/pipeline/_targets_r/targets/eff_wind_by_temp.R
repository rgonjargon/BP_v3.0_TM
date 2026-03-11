tar_target(eff_wind_by_temp,
  {
    cond <- data.frame(temp = quantile(data$temp, probs = c(0.25, 0.75)))
    temp_vals <- round(cond$temp, 1)
    ce <- conditional_effects(fit, effects = "wind", conditions = cond, re_formula = NA)
    dfs <- ce[sapply(ce, is.data.frame)]
    c_eff <- if (length(dfs) >= 2L) dfs[[2L]] else dfs[[1L]]
    c_eff <- c_eff %>% mutate(across(c(estimate__, lower__, upper__), exp))
    ggplot(c_eff, aes(x = effect1__, y = estimate__, ymin = lower__, ymax = upper__,
                      fill = cond__, color = cond__)) +
      theme_classic() +
      theme(legend.position = "bottom") +
      geom_ribbon(alpha = 0.3, colour = NA) +
      geom_line(linewidth = 1.5) +
      scale_fill_manual(values = c("#882255", "#6699CC"), name = "Temp (°F)") +
      scale_color_manual(values = c("#882255", "#6699CC"), name = "Temp (°F)") +
      labs(
        title = "Effect of wind on ozone",
        subtitle = paste0("Temperature held at 25th and 75th percentiles (", paste(temp_vals, collapse = " and "), " °F)"),
        y = "Ozone", x = "Wind"
      )
  }
)
