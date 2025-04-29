# Load necessary libraries
library(tidyverse)
library(caret)

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# For reproducibility
set.seed(1337)

# Prepare regression data (remove some unnecessary columns)
data_regression <- data_clean |>
  select(-listing_price, -price_development)

# Save the `data_regression` dataset to interim
write_csv(data_regression, "data/interim/data_regression.csv")

# Stratified split: Create training set (60%) stratified by 'neighborhood'
train_index <- createDataPartition(data_regression$neighborhood, p = 0.6, list = FALSE)
houses_train <- data_regression[train_index, ]

remaining_data <- data_regression[-train_index, ]

# Stratified split: Create test and validation sets (20% each, total 40% for test+validate)
test_val_index <- createDataPartition(remaining_data$neighborhood, p = 0.5, list = FALSE)
houses_test <- remaining_data[test_val_index, ]
houses_validate <- remaining_data[-test_val_index, ]

# Check the proportions and number of rows
data_split_proportions <- sapply(list(train = houses_train, test = houses_test, validate = houses_validate), nrow) / nrow(data_regression)
print(data_split_proportions)

# Save splits
write_csv(houses_train, "data/processed/houses_train.csv")
write_csv(houses_validate, "data/processed/houses_validate.csv")
write_csv(houses_test, "data/processed/houses_test.csv")
