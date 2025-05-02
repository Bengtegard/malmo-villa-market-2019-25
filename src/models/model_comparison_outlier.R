# Load necessary libraries
library(lme4)
library(performance)

# For reproducibility
set.seed(1337)

# Load the dataset
houses_train <- read.csv("data/processed/houses_train.csv")

# ------------------------- Outlier Removal -------------------------

# Remove outliers identified previously (rows 1348, 184, 943, 340, 1262, 678, 829)
houses_train_cleaned <- houses_train[-c(1347, 185, 341, 1261, 678), ]

# ------------------------- Model Fitting -------------------------

# Refit the mixed-effects model with the original training data
mixed_model <- lmer(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year + secondary_area +
        secondary_area_missing + (1 | neighborhood),
    data = houses_train
)

# Refit the mixed-effects model with the cleaned data (without outliers)
mixed_model_clean <- lmer(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year + secondary_area +
        secondary_area_missing + (1 | neighborhood),
    data = houses_train_cleaned
)

# ------------------------- Model Comparison ----------------------

# Compare AIC and BIC for both models
aic_comparison <- AIC(mixed_model, mixed_model_clean)
bic_comparison <- BIC(mixed_model, mixed_model_clean)

# Display AIC and BIC comparison
cat("\nAIC Comparison:\n")
print(aic_comparison)

cat("\nBIC Comparison:\n")
print(bic_comparison)

# ------------------------- R² Values -----------------------------

# Calculate R² values (Marginal and Conditional) for both models
r2_mixed_model <- r2(mixed_model)
r2_mixed_model_clean <- r2(mixed_model_clean)

# Display R² values for both models
cat("\nR² Values (Marginal / Conditional):\n")
cat("Original Mixed Model: ", round(r2_mixed_model$R2_marginal, 3), "/", round(r2_mixed_model$R2_conditional, 3), "\n")
cat("Cleaned Mixed Model:  ", round(r2_mixed_model_clean$R2_marginal, 3), "/", round(r2_mixed_model_clean$R2_conditional, 3), "\n")

# ------------------------- Save Model and Data ---------------------------

# Save fitted model without outliers
saveRDS(mixed_model_clean, "models/mixed_model_clean.rds")

# Save the cleaned dataset
write.csv(houses_train_cleaned, "data/processed/houses_train_cleaned.csv", row.names = FALSE)
