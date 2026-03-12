# DAG: v4 (exposure) → v3 (mediator); log_v1 (outcome) ~ v3, v4, v2 (covariate)
tar_target(dag, {
  basic_dag <- dagify(
    v3 ~ v4,
    log_v1 ~ v3,
    log_v1 ~ v4,
    log_v1 ~ v2,
    exposure = "v4",
    outcome = "log_v1",
    coords = list(
      x = c(v4 = 0, v3 = 1, v2 = 0.5, log_v1 = 2),
      y = c(v4 = 1, v3 = 1.1, v2 = 0.4, log_v1 = 1)
    )
  )
  basic_dag_plot <- basic_dag |>
    ggdag::tidy_dagitty() |>
    dplyr::mutate(
      var_type = dplyr::case_when(
        name == "v4" ~ "Exposure",
        name == "log_v1" ~ "Outcome",
        name == "v3" ~ "Mediator",
        name == "v2" ~ "Covariate"
      ),
      label = dplyr::case_match(
        name,
        "v4" ~ "v4",
        "v3" ~ "v3",
        "log_v1" ~ "log(v1)",
        "v2" ~ "v2"
      )
    )
  ggplot2::ggplot(basic_dag_plot, ggplot2::aes(x = x, y = y, xend = xend, yend = yend)) +
    ggdag::geom_dag_edges() +
    ggdag::geom_dag_point(ggplot2::aes(color = var_type), size = 21) +
    ggdag::geom_dag_text(
      ggplot2::aes(label = label),
      color = "white", fontface = "bold", size = 4
    ) +
    ggplot2::scale_color_manual(
      values = c(Exposure = "#882255", Mediator = "#6699CC", Outcome = "#999933", Covariate = "#CC6677"),
      guide = "none"
    ) +
    ggdag::theme_dag() +
    ggplot2::theme(plot.margin = ggplot2::margin(12, 12, 12, 12))
})
