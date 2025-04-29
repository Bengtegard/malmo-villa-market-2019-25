# Load necessary libraries
library(tidyverse)
library(lme4)
library(ggrepel)
library(broom.mixed)

# Load the saved model
mixed_model <- readRDS("models/final_mixed_model.rds")

# Augment the mixed model results with the broom package
augmented_mixed_model <- augment(mixed_model)

# Calculate studentized residuals
std_cond_resid <- rstudent(mixed_model)

# Get residual standard deviation
resid_sd <- sigma(mixed_model)

# Add studentized conditional residuals manually to the augmented model
augmented_mixed_model <- augmented_mixed_model %>%
    mutate(.std.cond.resid = std_cond_resid)

# Identify outliers based on studentized conditional residuals (> 3 or < -3)
outliers_std_cond <- augmented_mixed_model %>%
    filter(abs(.std.cond.resid) > 3)

# Print outliers based on studentized conditional residuals
print(outliers_std_cond)

# Plot: Studentized Residuals vs Fitted Values
outlier_plot <- ggplot(augmented_mixed_model, aes(x = .fitted, y = .std.cond.resid)) +
    geom_point() +
    geom_hline(yintercept = 0, color = "red") +
    geom_hline(yintercept = c(-2, 2), color = "blue", linetype = "dashed") +
    geom_text_repel(
        aes(label = ifelse(abs(.std.cond.resid) > 3.3, rownames(augmented_mixed_model), "")),
        size = 3,
        color = "red"
    ) +
    labs(
        x = "Fitted Values",
        y = "Studentized Conditional Residuals",
        title = "Studentized Residuals vs Fitted Values"
    )

# Save the plot
ggsave(
    filename = "reports/figures/outlier_plot.png",
    plot = outlier_plot,
    width = 10, height = 8
)
