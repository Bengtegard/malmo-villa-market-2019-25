# Load necessary libraries
library(tidyverse)
library(lme4)
library(broom.mixed)
library(sjPlot)
library(ggeffects)
library(see)
library(ggrepel)
library(scales)

# Load the theme
source("src/visualization/bengtegard_theme.R")

# Load the scaled dataset
houses_train_scaled <- read.csv("data/processed/houses_train_scaled.csv")

# Re-fit the model with standardized predictors
mixed_model_standardized <- lmer(
    log(house_price) ~ living_area + number_of_rooms + operating_cost +
        plot_area + year_built + year + secondary_area + secondary_area_missing + (1 | neighborhood),
    data = houses_train_scaled
)

# Save fitted model
saveRDS(mixed_model_standardized, "models/mixed_model_standardized.rds")

# ----- Fixed Effects Coefficient Plot -----
# Tidy model output with confidence intervals
fixed_eff_standardized <- broom.mixed::tidy(mixed_model_standardized, effects = "fixed", conf.int = TRUE)

# Exponentiate to interpret on original price scale
fixed_eff_exp_standardized <- fixed_eff_standardized |>
    mutate(across(c(estimate, conf.low, conf.high), exp),
        percent_change = (estimate - 1) * 100
    )

# Plot fixed effects
fixed_effects_plot <- ggplot(fixed_eff_exp_standardized, aes(x = estimate, y = term)) +
    geom_point() +
    geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
    scale_x_continuous(trans = "log10", limits = c(0.9, 1.5)) +
    labs(
        title = "Impact of Predictors on House Price (Log-Scale)",
        subtitle = "Exponentiated fixed effects with 95% confidence intervals",
        x = "Effect on House Price for One Standard Deviation Change",
        y = "Predictors"
    ) +
    bengtegard_theme() +
    geom_text(aes(label = paste0(round(percent_change, 1), "%")),
        hjust = 0.3, vjust = -2, size = 4, color = "#ff6347"
    )

# Save fixed effects plot
ggsave(
    filename = "reports/figures/fixed_effects_plot.png",
    plot = fixed_effects_plot,
    width = 10, height = 8
)

# ----- Random Effects Plot -----
random_effects_plot <- plot_model(mixed_model_standardized, type = "re", show.values = FALSE, show.p = FALSE) +
    labs(
        title = "Random Effects: Neighborhood Intercepts",
        x = "Random Effect Estimate",
        y = "Neighborhood"
    ) +
    bengtegard_theme()

# Save random effects plot
ggsave(
    filename = "reports/figures/random_effects_plot.png",
    plot = random_effects_plot,
    width = 14, height = 12
)
