# Load necessary libraries
library(ggmap)
library(dplyr)
library(sf)
library(ggplot2)
library(dotenv)
library(tidyverse)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/raw/hemnet_sold_properties.csv")

# Load the API key from .env
load_dotenv()
google_api_key <- Sys.getenv("GOOGLE_API_KEY")

# Register your Google API key (for ggmap)
register_google(key = google_api_key)

# Define the map center and zoom level for Malmö
malmo_center <- c(lon = 13.0038, lat = 55.6049)
zoom_level <- 11

# Fetch the base map
malmo_map <- get_map(location = malmo_center, zoom = zoom_level, maptype = "roadmap", source = "google")

# Prepare spatial data (assuming you have data with latitude and longitude)
malmo_data_sf <- data |>
  select(latitude, longitude, house_price, neighborhood) |>
  filter(
    latitude >= 55 & latitude <= 56,
    longitude >= 12 & longitude <= 14
  ) |>
  st_as_sf(coords = c("longitude", "latitude"))

# Generate the map plot
malmo_map_plot <- ggmap(malmo_map) +
  geom_sf(data = malmo_data_sf, aes(color = log(house_price)), alpha = 0.5, size = 1.5, inherit.aes = FALSE) +
  scale_color_viridis_c(name = "Log of Final price (SEK)") +
  ggtitle("House Prices in Malmö from 2019 to 2025") +
  bengtegard_theme() +
  labs(caption = "Data from hemnet.se") +
  theme(
    legend.position = "bottom",
    axis.title.x = element_blank(),
    axis.title.y = element_blank()
  )

# Save the map plot
ggsave(
  filename = "reports/figures/malmo_map.png", # Path to save
  plot = malmo_map_plot, # Plot object to save
  width = 12, height = 8 # Plot dimensions
)
