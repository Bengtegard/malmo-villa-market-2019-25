# Load necessary libraries
library(tidyverse)
library(ggpmisc)
library(ggrepel)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data_regression <- read_csv("data/interim/data_regression.csv")

# Create the plot
pred3 <- ggplot(data_regression, aes(x = operating_cost, y = house_price / 1e6)) +
    geom_point(alpha = 0.5, color = "#1B9E77") +
    stat_poly_line() +
    stat_poly_eq(use_label(c("R2"))) +
    geom_text_repel(
        aes(label = ifelse(operating_cost > 150000, rownames(data_regression), "")),
        size = 3,
        color = "red"
    ) +
    labs(
        x = "Operating Cost",
        y = "House Price (MSEK)"
    ) +
    bengtegard_theme()

# Save the plot
ggsave(
    filename = "reports/figures/pred3_operating_cost_vs_price.png",
    plot = pred3,
    width = 10,
    height = 8
)
