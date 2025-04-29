# Load necessary libraries
library(tidyverse)
library(scales)
library(viridis)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Function for converting millions and adding "millions (SEK)"
million_sek_format <- function(x) {
  paste0(format(x / 1e6, big.mark = ","), " millions (SEK)")
}

# Aggregate the data by neighborhood to get the average price
top10_neighborhoods <- data_clean |>
  group_by(neighborhood) |>
  filter(
    (!(neighborhood %in% c("Torg", "By"))), # remove incorrect neighborhoods
    n() > 5, # keep only neighborhoods with 5+ sold houses
    latitude >= 0 & longitude >= 0
  ) |>
  summarise(
    median_price = median(house_price, na.rm = TRUE),
    n = n()
  ) |>
  arrange(desc(median_price)) |>
  slice_head(n = 10)

# Bar plot for the top 10 most expensive neighborhoods
top10_neighborhoods <- ggplot(top10_neighborhoods, aes(x = reorder(neighborhood, median_price), y = median_price / 1e6, fill = median_price)) +
  geom_col() +
  scale_fill_viridis_c(labels = million_sek_format, name = "") +
  bengtegard_theme() +
  labs(
    title = "House Prices in the 10 Most Expensive Neighborhoods of Malmö",
    x = "Neighborhood",
    y = "Median House Price in (MSEK)",
    caption = "Data from Hemnet.se"
  ) +
  geom_text(aes(label = median_price / 1e6),
    color = "#ffffff",
    hjust = 1.5
  ) +
  coord_flip()

# Save the plot
ggsave(
  filename = "reports/figures/top10_neighborhoods.png",
  plot = top10_neighborhoods,
  width = 12, height = 8
)
