tar_target(plot_ozone_temp, {
  pred_grid <- data %>%
    data_grid(v4 = seq_range(v4, n = 200), v3 = mean(v3), v2 = mean(v2)) %>%
    add_epred_draws(fit, ndraws = 100) %>%
    filter(.category == "logv1") %>%
    mutate(.epred = exp(.epred))
  v3_val <- round(mean(data$v3), 1)
  ggplot(pred_grid, aes(x = v4, y = .epred)) +
    theme_classic() +
    stat_lineribbon(.width = .95, alpha = 0.8, fill = "#882255", color = "black") +
    geom_point(data = data, aes(x = v4, y = v1), shape = 21, size = 2, inherit.aes = FALSE) +
    labs(
      title = "v1 vs v4",
      subtitle = paste0("v3 and v2 held at mean (", v3_val, ")"),
      y = "v1", x = "v4"
    )
})
