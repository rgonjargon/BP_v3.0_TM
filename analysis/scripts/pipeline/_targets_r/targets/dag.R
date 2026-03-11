# DAG: left-to-right layout (exposure → mediator → outcome); nodes 50% larger
tar_target(dag, {
  basic_dag <- dagify(
    wind ~ temp,
    log_ozone ~ wind,
    log_ozone ~ temp,
    exposure = "temp",
    outcome = "log_ozone",
    coords = list(
      x = c(temp = 0, wind = 1, log_ozone = 2),
      y = c(temp = 1, wind = 1.1, log_ozone = 1)
    )
  )
  basic_dag_plot <- basic_dag |>
    ggdag::tidy_dagitty() |>
    dplyr::mutate(
      var_type = dplyr::case_when(
        name == "temp" ~ "Exposure",
        name == "log_ozone" ~ "Outcome",
        name == "wind" ~ "Mediator"
      ),
      label = dplyr::case_match(
        name,
        "temp" ~ "temp",
        "wind" ~ "wind",
        "log_ozone" ~ "log(O3)"
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
      values = c(Exposure = "#882255", Mediator = "#6699CC", Outcome = "#999933"),
      guide = "none"
    ) +
    ggdag::theme_dag() +
    ggplot2::theme(plot.margin = ggplot2::margin(12, 12, 12, 12))
})
