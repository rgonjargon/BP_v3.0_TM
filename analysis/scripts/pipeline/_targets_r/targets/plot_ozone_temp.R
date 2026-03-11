tar_target(plot_ozone_temp, {
  pred_grid <- data %>%
    data_grid(temp = seq_range(temp, n = 200), wind = mean(wind)) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    filter(.category == "logozone") %>%
    mutate(.epred = exp(.epred))
  wind_val <- round(mean(data$wind), 1)
  ggplot(pred_grid, aes(x = temp, y = .epred)) +
    theme_classic() +
    stat_lineribbon(.width = .95, alpha = 0.8, fill = "#882255", color = "black") +
    geom_point(data = data, aes(x = temp, y = ozone), shape = 21, size = 2, inherit.aes = FALSE) +
    labs(
      title = "Ozone vs temperature",
      subtitle = paste0("Wind held at mean (", wind_val, " mph)"),
      y = "Ozone (ppb)", x = "Temp (°F)")
})
