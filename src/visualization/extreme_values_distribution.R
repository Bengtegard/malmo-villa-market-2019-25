# Load libraries
library(ggplot2)
library(scales)
library(tidyverse)

# Load the custom theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Create the plot
p_extreme_values <- ggplot(data_clean, aes(
    x = house_price,
    fill = (house_price == 20000000 | house_price > 20000000))) +
  geom_histogram(bins = 30) +
  scale_x_continuous(
    labels = scales::comma_format(scale = 1e-6, suffix = "M"),
    breaks = seq(0, max(data_clean$house_price, na.rm = TRUE), by = 0.5e7)) +
  coord_cartesian(
    xlim = c(1300000, 30000000),
    ylim = c(0, 20)
  ) +
  scale_fill_manual(values = c("TRUE" = "#FF6347", "FALSE" = "#1B9E77")) + 
  bengtegard_theme() +
  theme(legend.position = "bottom") +
  labs(
    y = "Frequency", 
    x = "Final House Price (MSEK)",
    fill = "Extreme Value"
  )

# Save the plot
ggsave(
  filename = "reports/figures/extreme_values_distribution.png",
  plot = p_extreme_values,
  width = 8, height = 6
)
