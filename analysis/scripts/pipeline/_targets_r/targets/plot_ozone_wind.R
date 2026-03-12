tar_target(plot_ozone_wind, {
  v4_cond <- quantile(data$v4, 0.9)
  pred_grid <- data %>%
    data_grid(v3 = seq_range(v3, n = 200), v4 = v4_cond, v2 = mean(v2)) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    filter(.category == "logv1") %>%
    mutate(.epred = exp(.epred))
  ggplot(pred_grid, aes(x = v3, y = .epred)) +
    theme_classic() +
    stat_lineribbon(.width = .95, alpha = 0.8, fill = "#6699CC", color = "black") +
    geom_point(data = data, aes(x = v3, y = v1), shape = 21, size = 2, inherit.aes = FALSE) +
    labs(
      title = "v1 vs v3",
      subtitle = paste0("v4 held at 90th percentile (", round(v4_cond, 1), ")"),
      y = "v1", x = "v3"
    )
})
