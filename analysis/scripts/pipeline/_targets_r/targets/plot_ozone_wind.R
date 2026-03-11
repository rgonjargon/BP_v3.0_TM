tar_target(plot_ozone_wind, {
  temp_cond <- quantile(data$temp, 0.9)
  pred_grid <- data %>%
    data_grid(wind = seq_range(wind, n = 200), temp = temp_cond) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    filter(.category == "logozone") %>%
    mutate(.epred = exp(.epred))
  ggplot(pred_grid, aes(x = wind, y = .epred)) +
    theme_classic() +
    stat_lineribbon(.width = .95, alpha = 0.8, fill = "#6699CC", color = "black") +
    geom_point(data = data, aes(x = wind, y = ozone), shape = 21, size = 2, inherit.aes = FALSE) +
    labs(
      title = "Ozone vs wind",
      subtitle = paste0("Temp held at 90th percentile (", round(temp_cond, 1), " °F)"),
      y = "Ozone (ppb)", x = "Wind (mph)"
    )
})
