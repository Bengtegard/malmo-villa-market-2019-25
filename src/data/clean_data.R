# Load libraries
library(tidyverse)
library(dplyr)
library(stringr)
library(lubridate)

# Load raw data
data <- read_csv("data/raw/hemnet_sold_properties.csv")

# Rename columns
data <- data |>
  rename(
    house_price = slutpris,
    listing_price = utgangspris,
    price_development = prisutv,
    number_of_rooms = antal_rum,
    living_area = boarea,
    secondary_area = biarea,
    plot_area = tomtarea,
    year_built = byggar,
    operating_cost = driftkostnad,
    sale_date = sälj_datum,
    neighborhood = område
  ) |>
  mutate(neighborhood = str_to_title(neighborhood))

# Convert Swedish months in dates
swedish_months <- c(
  "januari" = "January", "februari" = "February", "mars" = "March",
  "april" = "April", "maj" = "May", "juni" = "June", "juli" = "July",
  "augusti" = "August", "september" = "September", "oktober" = "October",
  "november" = "November", "december" = "December"
)

data <- data |>
  mutate(
    sale_date = str_replace_all(sale_date, swedish_months),
    sale_date = dmy(sale_date)
  )

# Final cleaning
data_clean <- data |>
  mutate(
    secondary_area_missing = ifelse(is.na(secondary_area), 1, 0),
    secondary_area = ifelse(is.na(secondary_area), 0, secondary_area),
    sale_date = as.Date(sale_date),
    month = month(sale_date),
    year = year(sale_date),
    neighborhood = as.character(neighborhood)
  ) |>
  filter(
    house_price < 25000000, # remove one extreme outlier
    !is.na(number_of_rooms),
    !is.na(operating_cost),
    !is.na(price_development),
    !is.na(neighborhood),
    !is.na(living_area),
    !is.na(plot_area),
    !is.na(year_built),
    !neighborhood %in% c("Malmö", "Torg", "Tomt", "Trädgård")
  ) |>
  mutate(
    neighborhood = case_when(
      neighborhood == "By" ~ "Kyrkby",
      neighborhood == "Kyrby" ~ "Kyrkby",
      TRUE ~ neighborhood
    ),
    neighborhood = as.factor(neighborhood)
  )

# Save the cleaned data
write_csv(data_clean, "data/processed/hemnet_cleaned_data.csv")
