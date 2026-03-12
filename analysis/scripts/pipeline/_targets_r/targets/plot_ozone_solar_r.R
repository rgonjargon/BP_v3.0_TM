tar_target(plot_ozone_solar_r, {
  pred_grid <- data %>%
    data_grid(v2 = seq_range(v2, n = 200), v3 = mean(v3), v4 = mean(v4)) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    filter(.category == "logv1") %>%
    mutate(.epred = exp(.epred))
  ggplot(pred_grid, aes(x = v2, y = .epred)) +
    theme_classic() +
    stat_lineribbon(.width = .95, alpha = 0.8, fill = "#CC6677", color = "black") +
    geom_point(data = data, aes(x = v2, y = v1), shape = 21, size = 2, inherit.aes = FALSE) +
    labs(
      title = "v1 vs v2",
      subtitle = "v3 and v4 held at mean",
      y = "v1", x = "v2"
    )
})
