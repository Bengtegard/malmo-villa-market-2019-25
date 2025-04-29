# Load necessary libraries
library(knitr)
library(kableExtra)
library(MuMIn)
library(lme4)
library(Metrics)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Load the splits
houses_train <- read_csv("data/processed/houses_train.csv")
houses_validate <- read_csv("data/processed/houses_validate.csv")

# ---------------------- Model Fitting ------------------------------

# Model 1: Linear regression with only living_area
linear_model <- lm(log(house_price) ~ living_area, data = houses_train)

# Model 2: Multiple linear regression with all numeric predictors
mlr_model <- lm(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year + secondary_area + secondary_area_missing,
    data = houses_train
)

# Model 3: Multiple linear regression with all predictors (including categorical variable neighborhood)
mlr_neighborhood <- lm(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year + secondary_area + secondary_area_missing + neighborhood,
    data = houses_train
)

# Model 4: Mixed-effects model with neighborhood as random effect
mixed_model <- lmer(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year + secondary_area + secondary_area_missing + (1 | neighborhood),
    data = houses_train
)

# ---------------------- Model Evaluation ------------------------------

# Predictions
val_pred_m1 <- predict(linear_model, newdata = houses_validate)
val_pred_m2 <- predict(mlr_model, newdata = houses_validate)
val_pred_m3 <- predict(mlr_neighborhood, newdata = houses_validate)
val_pred_m4 <- predict(mixed_model, newdata = houses_validate, allow.new.levels = TRUE)

# Actual log house prices
actual_values <- log(houses_validate$house_price)

# Calculate RMSE for each model
rmse_m1 <- rmse(actual_values, val_pred_m1)
rmse_m2 <- rmse(actual_values, val_pred_m2)
rmse_m3 <- rmse(actual_values, val_pred_m3)
rmse_m4 <- rmse(actual_values, val_pred_m4)

# Calculate range of the actual values
val_range <- max(actual_values) - min(actual_values)

# Normalize RMSE using the range (min-max)
nrmse_m1 <- rmse_m1 / val_range
nrmse_m2 <- rmse_m2 / val_range
nrmse_m3 <- rmse_m3 / val_range
nrmse_m4 <- rmse_m4 / val_range

# Format NRMSE for display
nrmse_fmt <- function(x) paste0(round(x, 4), " (", round(x * 100, 2), "%)")

# Get conditional and marginal R² for mixed model
r2_mixed <- r.squaredGLMM(mixed_model)

# Build performance table
regression_results <- data.frame(
    Model = c(
        "Linear Regression (Living Area)",
        "Multiple Linear Regression (Numerical Predictors)",
        "Multiple Linear Regression (including Neighborhood)",
        "Mixed Effects Model"
    ),
    `Residual Standard Error` = round(c(
        sigma(linear_model),
        sigma(mlr_model),
        sigma(mlr_neighborhood),
        sigma(mixed_model)
    ), 4), # rounding to 4 decimals
    `R squared` = c(
        round(summary(linear_model)$r.squared, 3),
        round(summary(mlr_model)$r.squared, 3),
        round(summary(mlr_neighborhood)$r.squared, 3),
        paste0(round(r2_mixed[1, 2], 3), "¹") # Conditional R² with superscript ¹
    ),
    `Adjusted R squared` = c(
        round(summary(linear_model)$adj.r.squared, 3),
        round(summary(mlr_model)$adj.r.squared, 3),
        round(summary(mlr_neighborhood)$adj.r.squared, 3),
        paste0(round(r2_mixed[1, 1], 3), "²") # Marginal R² with superscript ²
    ),
    AIC = round(c(
        AIC(linear_model),
        AIC(mlr_model),
        AIC(mlr_neighborhood),
        AIC(mixed_model)
    ), 0), # rounding AIC to integer
    BIC = round(c(
        BIC(linear_model),
        BIC(mlr_model),
        BIC(mlr_neighborhood),
        BIC(mixed_model)
    ), 0), # rounding BIC to integer

    RMSE = round(c(
        rmse_m1,
        rmse_m2,
        rmse_m3,
        rmse_m4
    ), 4), # rounding RMSE to 2 decimals

    NRMSE = c(
        nrmse_fmt(nrmse_m1),
        nrmse_fmt(nrmse_m2),
        nrmse_fmt(nrmse_m3),
        nrmse_fmt(nrmse_m4)
    ),
    check.names = FALSE
)

# HTML table for model assessment
table_html <- kable(regression_results, format = "html", caption = "Model Performance on Validation set") |>
    kable_styling(
        bootstrap_options = c("striped", "hover", "condensed"),
        full_width = FALSE, position = "center"
    ) |>
    column_spec(1, bold = TRUE) |>
    column_spec(2:ncol(regression_results), width = "150px")

# Adding footnotes
table_html_footnote <- add_footnote(
    table_html,
    label = c(
        "¹ <span style='font-size: 10px;'>Conditional R² (R² = 0.785) includes both fixed and random effects.</span>",
        "² <span style='font-size: 10px;'> Marginal R² (R² = 0.246) considers only fixed effects.</span>"
    ),
    notation = "none",
    escape = FALSE
)

# Save the table
save_kable(table_html_footnote, file = "reports/tables/model_performance.html")

# ---------------------- Model Comparison Plot ------------------------------

# Get relevant data for my model comparison plot
validation_results <- bind_rows(
    tibble(model = "Linear", pred = val_pred_m1),
    tibble(model = "Multiple", pred = val_pred_m2),
    tibble(model = "MLR + Neighborhood", pred = val_pred_m3),
    tibble(model = "Mixed", pred = val_pred_m4)
) |>
    mutate(
        actual = rep(log(houses_validate$house_price), 4),
        model = factor(model),
        price_actual = exp(actual),
        price_pred = exp(pred)
    )

rmse_lookup <- tibble(
    model = factor(c("Linear", "Multiple", "MLR + Neighborhood", "Mixed")),
    dist = -c(rmse_m1, rmse_m2, rmse_m3, rmse_m4)
)

validation_results <- left_join(validation_results, rmse_lookup, by = "model")

# Create plot for all fitted models for visualization
comparison_plot <- ggplot(validation_results, aes(x = price_actual / 1e6, y = price_pred / 1e6)) +
    geom_point(alpha = 0.5, color = "black") +
    geom_smooth(method = "lm", se = FALSE, aes(group = model, color = model), alpha = 0.7, linewidth = 1.2) + # Fitted lines for each model
    geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "#ff0000") +
    labs(
        title = "Comparison of Fitted Regression Lines Across Models",
        x = "Actual Price (MSEK)",
        y = "Predicted Price (MSEK)",
        color = "Model"
    ) +
    scale_color_manual(values = c(
        "Linear" = "#4b4bc2",
        "Multiple" = "#d45b5b",
        "MLR + Neighborhood" = "#88e088",
        "Mixed" = "#aa57dd"
    )) +
    bengtegard_theme() +
    theme(
        legend.position = "bottom",
        plot.title = element_text(hjust = 0.5),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12)
    ) +
    coord_fixed(ratio = 1)

# Save models
saveRDS(linear_model, "models/linear_model.rds")
saveRDS(mlr_model, "models/mlr_model.rds")
saveRDS(mlr_model, "models/mlr_neighborhood.rds")
saveRDS(mixed_model, "models/mixed_model.rds")

# Save the plot
ggsave(
    filename = "reports/figures/model_comparison_plot.png",
    plot = comparison_plot,
    width = 10, height = 8
)
