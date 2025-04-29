# Load libraries
library(ggplot2)
library(scales)
library(tidyverse)

# Load the theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Plot
p_log_price_dist <- ggplot(data_clean, aes(x = log(house_price))) +
  geom_histogram(fill = "#1B9E77") +
  scale_x_continuous(
    labels = scales::number_format(accuracy = 0.01)
  ) +
  bengtegard_theme() +
  labs(
    y = "Frequency", 
    x = "Log of Final House Price",
    title = "Distribution of Log-Transformed House Prices"
  )

# Save
ggsave(
  filename = "reports/figures/log_price_distribution.png",
  plot = p_log_price_dist,
  width = 8, height = 6
)
