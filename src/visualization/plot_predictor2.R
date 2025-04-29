# Load necessary libraries
library(tidyverse)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data_regression <- read_csv("data/interim/data_regression.csv")

# Create the plot
pred2 <- ggplot(data_regression, aes(
    x = factor(number_of_rooms),
    y = house_price / 1e6
)) +
    geom_point(alpha = 0.5, size = 2, color = "#1B9E77") +
    scale_y_continuous(labels = scales::comma) +
    labs(
        x = "Number of Rooms",
        y = "House Price (MSEK)"
    ) +
    bengtegard_theme()

# Save the plot
ggsave(
    filename = "reports/figures/pred2_rooms_vs_price.png",
    plot = pred2,
    width = 10,
    height = 8
)
