# Load the data
houses_train_cleaned <- read.csv("data/processed/houses_train_cleaned.csv")

# Standardize all continuous predictors
houses_train_scaled_all <- houses_train_cleaned |>
    mutate(across(c(living_area, number_of_rooms, operating_cost, plot_area, secondary_area, year_built, year), scale))

# Save the scaled data
write.csv(houses_train_scaled_all, "data/processed/houses_train_scaled.csv")
