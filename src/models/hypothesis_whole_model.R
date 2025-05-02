# Load required package
library(lme4)

# Load the dataset
houses_train_cleaned <- read.csv("data/processed/houses_train_cleaned.csv")

# Load the final model
final_mixed_model <- readRDS("models/mixed_model_clean.rds")

# -------------------------------
# 1. Define competing models
# -------------------------------

# Full model: Includes fixed effects and a random intercept for neighborhood
model_full <- lmer(
    log(house_price) ~ living_area + number_of_rooms +
        operating_cost + plot_area + year_built + year +
        secondary_area + secondary_area_missing +
        (1 | neighborhood),
    data = houses_train_cleaned,
    REML = FALSE # Use ML for model comparison
)

# Null model: Only includes the random effect (no fixed predictors)
model_null <- lmer(
    log(house_price) ~ 1 + (1 | neighborhood),
    data = houses_train_cleaned,
    REML = FALSE
)

# -------------------------------
# 2. Compare models using Likelihood Ratio Test
# -------------------------------

comparison <- anova(model_null, model_full)

# -------------------------------
# 3. Report results
# -------------------------------

print(comparison)

# Clear interpretation
p_value <- comparison$`Pr(>Chisq)`[2]

cat("\n--- Model Comparison Summary ---\n")
if (p_value < 0.05) {
    cat("The full model explains significantly more variation than the null model (p =", round(p_value, 4), ").\n")
    cat("=> The fixed effects collectively contribute meaningfully to predicting house prices.\n")
} else {
    cat("There is no significant difference between the models (p =", round(p_value, 4), ").\n")
    cat("=> The fixed effects do not add explanatory power beyond the random effect.\n")
}
