# Load necessary libraries
library(tidyverse)
library(ggpmisc)
library(ggrepel)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data_regression <- read_csv("data/interim/data_regression.csv")

# Create the plot
pred4 <- ggplot(data_regression, aes(x = plot_area, y = house_price / 1e6)) +
    geom_point(alpha = 0.5, color = "#1B9E77") +
    stat_poly_line() +
    stat_poly_eq(use_label(c("R2"))) +
    geom_text_repel(
        aes(label = ifelse(plot_area > 2300, rownames(data_clean), "")),
        size = 3,
        color = "red"
    ) +
    labs(
        x = "Plot Area (m²)",
        y = "House Price (MSEK)"
    ) +
    bengtegard_theme()

# Save the plot
ggsave(
    filename = "reports/figures/pred4_plot_area_vs_price.png",
    plot = pred4,
    width = 10,
    height = 8
)
