# Load necessary libraries
library(ggplot2)
library(dplyr)
library(lubridate)
library(scales)
library(tidyverse)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Aggregate sales trends data
sales_trends_df <- data_clean |>
  group_by(year, month) |>
  summarise(sales_count = n(), .groups = "drop") |>
  mutate(Date = as.Date(paste(year, month, "01", sep = "-")))

# Create sales trends plot
sales_trends_plot <- ggplot(sales_trends_df, aes(x = Date, y = sales_count)) +
  geom_line(color = "#1B9E77", size = 1) +
  geom_point(color = "#D95F02", size = 1.5) +
  labs(
    title = "Number of Houses Sold in Malmö from 2019 to 2025",
    x = "Year and Month",
    y = "Sales Frequency",
    caption = "Data from hemnet.se"
  ) +
  scale_x_date(
    breaks = date_breaks("6 months"),
    labels = date_format("%b\n%Y")
  ) +
  scale_y_continuous(labels = label_comma()) +
  bengtegard_theme() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Save the plot
ggsave(
  filename = "reports/figures/sales_trends_plot.png",
  plot = sales_trends_plot,
  width = 12, height = 8
)
