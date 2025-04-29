# Load necessary libraries
library(ggplot2)
library(scales)
library(tidyverse)

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Load the theme
source("src/visualization/bengtegard_theme.R")

# Plot
price_dist_plot <- ggplot(data_clean, aes(x = house_price)) +
  geom_histogram(fill = "#1B9E77") +
  geom_vline(aes(xintercept = mean(house_price, na.rm = TRUE)),
    color = "#e24b1d", linetype = "dashed", linewidth = 1
  ) +
  geom_vline(aes(xintercept = median(house_price, na.rm = TRUE)),
    color = "#4a4aa7", linetype = "dashed", linewidth = 1
  ) +
  scale_x_continuous(
    labels = comma_format(scale = 1e-6, suffix = "M"),
    breaks = seq(0, max(data_clean$house_price, na.rm = TRUE), by = 0.5e7)
  ) +
  bengtegard_theme() +
  labs(
    y = "Frequency",
    x = "Final House Price in (MSEK)",
    caption = "Blue line = Median price | Red line = Mean price"
  )

# Save plot
ggsave(
  filename = "reports/figures/house_price_distribution.png",
  plot = price_dist_plot,
  width = 8, height = 6
)
