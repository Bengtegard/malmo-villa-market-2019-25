# Load necessary libraries
library(tidyverse)
library(scales)
library(viridis)
library(ggridges)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import the data
data <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Aggregate the data by neighborhood to get the average price
top10_neighborhoods <- data |>
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

# Filter data to include only the top 10 expensive neighborhoods
top10_names <- top10_neighborhoods$neighborhood

data_top10 <- data_clean |>
  select(neighborhood, house_price) |>
  filter(neighborhood %in% top10_names)

# Ridge plot of price distributions
top10_distribution <- ggplot(data_top10, aes(x = house_price / 1e6, y = fct_reorder(neighborhood, house_price), fill = neighborhood)) +
  geom_jitter(data = data_top10, height = 0.1, alpha = 0.4, shape = 21) +
  geom_density_ridges(scale = 1.5, alpha = 0.7, color = "white") +
  scale_x_continuous(name = "Final House Price (MSEK)") +
  scale_y_discrete(name = "Neighborhood") +
  bengtegard_theme() +
  labs(
    title = "Distribution of House Prices in Malmö's Most Expensive Neighborhoods",
    caption = "Data from Hemnet.se"
  ) +
  theme(legend.position = "none")

# Save
ggsave(
  filename = "reports/figures/top10_neighborhoods_distribution.png",
  plot = top10_distribution,
  width = 12, height = 8
)
