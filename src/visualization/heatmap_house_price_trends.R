# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(viridis)
library(lubridate)
library(tidyverse)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Aggregate data
data_summary <- data_clean |>
  group_by(year, month) |>
  summarise(avg_price = median(house_price, na.rm = TRUE)) |>
  ungroup()

# Create a complete grid of all year-month combinations (from 2020 to 2024)
complete_grid <- expand.grid(
  year = 2020:2024,  
  month = 1:12 
)

# Join the complete grid with your summarized data
data_complete <- complete_grid |>
  left_join(data_summary, by = c("year", "month")) |>
  mutate(avg_price = ifelse(is.na(avg_price), NA, avg_price),
         month = factor(month, levels = 1:12, labels = month.abb))

# Function for converting millions and adding "millions (SEK)"
million_sek_format <- function(x) {
  paste0(format(x / 1e6, big.mark = ","), " millions (SEK)")
}

# Create the heatmap
ggplot(data_complete, aes(x = month, y = year, fill = avg_price)) +
  geom_tile() +
  scale_fill_viridis_c(labels = million_sek_format) +
  labs(
    title = "Monthly Median Sale Prices of Houses in Malmö (2020–2024)",
    subtitle = "Aggregated Based on Final Sale Prices (Median)",
    x = "Month",
    y = "Year",
    fill = "Average Sale Price",
    caption = "Data from Hemnet.se"
  ) +
  geom_text(aes(label = round((avg_price / 1e6), digits = 3)),
            color = "white", size = 3) +
  bengtegard_theme()

# Save the plot
ggsave(
  filename = "reports/figures/heatmap_house_price_trends.png",
  plot = last_plot(),
  width = 12, height = 8
)
