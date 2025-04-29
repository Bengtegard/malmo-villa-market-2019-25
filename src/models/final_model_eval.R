# Load necessary libraries
library(lme4)
library(ggplot2)

# Load the theme
source("src/visualization/bengtegard_theme.R")

# Load the best model (cleaned mixed model)
mixed_model_clean <- readRDS("models/mixed_model_clean.rds")

# Load the test set (adjust path as needed)
houses_test <- read.csv("data/processed/houses_test.csv")

# Predict on the test set for final unbiased evaluation
final_predictions <- predict(mixed_model_clean, newdata = houses_test, allow.new.levels = TRUE)

# Transform predictions to the original scale (since the log was used)
predicted_prices_test <- exp(final_predictions)

# Actual prices from the test set
actual_prices_test <- houses_test$house_price

# Plot Predicted Price vs Actual Price
test_best_model <- ggplot(houses_test, aes(x = actual_prices_test / 1e6, y = predicted_prices_test / 1e6)) +
    geom_point(alpha = 0.6, color = "#1B9E77") +
    geom_smooth(method = "lm", se = FALSE, color = "darkred") +
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray30") +
    labs(
        x = "Actual House Price (MSEK)",
        y = "Predicted House Price (MSEK)",
        title = "Final Model Predictions on Test Set",
        caption = "Dashed line shows perfect predictions (y = x)."
    ) +
    bengtegard_theme()

# Save plot
ggsave(
    filename = "reports/figures/final_model_predictions.png",
    plot = test_best_model,
    width = 8, height = 6
)
