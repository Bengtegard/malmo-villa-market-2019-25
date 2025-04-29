# Load necessary libraries
library(tidyverse)
library(ggpmisc) # For stat_poly_line() and stat_poly_eq()
library(ggrepel) # For geom_text_repel()

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data_regression <- read_csv("data/interim/data_regression.csv")

# Create the plot
pred1 <- ggplot(data_regression, aes(x = living_area, y = house_price / 1e6)) +
    geom_point(alpha = 0.5, color = "#1B9E77") +
    stat_poly_line() +
    stat_poly_eq(use_label(c("R2"))) +
    geom_text_repel(
        aes(label = ifelse(living_area > 360, rownames(data_regression), "")),
        size = 3,
        color = "red"
    ) +
    labs(
        x = "Living Area (m²)",
        y = "House Price (MSEK)",
        title = "House Price vs Living Area"
    ) +
    bengtegard_theme() # Apply your custom theme

# Save the plot
ggsave(
    filename = "reports/figures/pred1_living_area_vs_price.png",
    plot = pred1,
    width = 10,
    height = 8
)
