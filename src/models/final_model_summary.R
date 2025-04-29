# Load necessary libraries
library(lme4)
library(Metrics)
library(MuMIn)
library(knitr)
library(kableExtra)
library(sjPlot)
library(htmltools)

# Load the models
mixed_model_clean <- readRDS("models/mixed_model_clean.rds")
mixed_model_standardized <- readRDS("models/mixed_model_standardized.rds")

# Load the test set (adjust path as needed)
houses_test <- read.csv("data/processed/houses_test.csv")

# Predictions on the test set
final_predictions <- predict(mixed_model_clean, newdata = houses_test, allow.new.levels = TRUE)

# Transform predictions back to the original scale
predicted_prices_test <- exp(final_predictions)
actual_prices_test <- houses_test$house_price

# Calculate RMSE
final_rmse <- sqrt(mean((actual_prices_test - predicted_prices_test)^2))

# Format NRMSE for display
nrmse_fmt <- function(x) paste0(round(x, 4), " (", round(x * 100, 2), "%)")

# Calculate RMSE
final_rmse <- sqrt(mean((actual_prices_test - predicted_prices_test)^2))

# Calculate value range for NRMSE
test_range <- max(actual_prices_test) - min(actual_prices_test)
nrmse_final <- final_rmse / test_range

# Conditional and Marginal R² for final model
r2_final <- r.squaredGLMM(mixed_model_clean)

# Create summary data frame
final_model_summary <- data.frame(
    Metric = c(
        "Residual Standard Error",
        "Marginal R² (Fixed effects)",
        "Conditional R² (Fixed + Random effects)",
        "AIC",
        "BIC",
        "RMSE (in millions SEK)",
        "NRMSE"
    ),
    Value = c(
        round(sigma(mixed_model_clean), 3),
        round(r2_final[1, 1], 4), # Marginal R²
        round(r2_final[1, 2], 4), # Conditional R²
        round(AIC(mixed_model_clean), 1),
        round(BIC(mixed_model_clean), 1),
        round(final_rmse, 0), # RMSE in millions SEK
        nrmse_fmt(nrmse_final)
    )
)

# Format the summary table
final_model_kable <- kable(final_model_summary, caption = "Final Model Performance on Test set", format = "html") |>
    kable_styling(
        bootstrap_options = c("striped", "hover", "condensed"),
        full_width = FALSE,
        position = "center"
    ) |>
    column_spec(1, bold = TRUE) %>%
    column_spec(2:ncol(final_model_summary), width = "150px")

# Save the table
save_kable(
    final_model_kable,
    file = "reports/tables/final_model_summary.html"
)

# ----- Model Table with 95% CI and significance for predictors -----
model_output <- tab_model(
    mixed_model_standardized,
    show.re.var = TRUE,
    pred.labels = c(
        "(Intercept)", "Living area (m²)", "Number of rooms", "Operating cost (SEK)",
        "Plot area (m²)", "Year built", "Sale Year", "Secondary area", "Secondary area missing (Yes/No)"
    ),
    dv.labels = "Impact of Predictors on House Sale Price",
    show.p = TRUE,
    p.style = "numeric",
    digits = 3,
    string.ci = "95% CI",
    transform = NULL
)

# Convert the sjTable object to HTML using as.character
html_output <- as.character(model_output)

# Write the HTML output to a file
writeLines(html_output, "reports/tables/standardized_coefficient_table.html")
