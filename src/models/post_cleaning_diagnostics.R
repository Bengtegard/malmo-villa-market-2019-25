# Load necessary libraries
library(tidyverse)
library(ggrepel)
library(broom.mixed)
library(performance)
library(see)

# Load the cleaned model
mixed_model_clean <- readRDS("models/mixed_model_clean.rds")

# Augment the cleaned model results
augmented_mixed_model_clean <- augment(mixed_model_clean)

# Plot: Residual Distribution
residual_plot <- ggplot(augmented_mixed_model_clean, aes(x = .resid)) +
    geom_density(fill = "darkblue", alpha = 0.7) +
    labs(
        title = "Residual Distribution",
        x = "Residuals",
        y = "Frequency"
    )

# Save the residual distribution plot
ggsave(
    filename = "reports/figures/residual_distribution.png",
    plot = residual_plot,
    width = 10, height = 8
)

# Generate the diagnostic plot using check_model
diagnostic_plot <- check_model(mixed_model_clean)

# Save the diagnostic plot
ggsave(
    filename = "reports/figures/diagnostic_plot.png",
    plot = plot(diagnostic_plot),
    width = 12, height = 10
)
