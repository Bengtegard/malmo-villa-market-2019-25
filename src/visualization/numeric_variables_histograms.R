# Load libraries
library(tidyverse)

# Load custom theme
source("src/visualization/bengtegard_theme.R")

# Import cleaned data
data_clean <- read_csv("data/processed/hemnet_cleaned_data.csv")

# Plot all numeric variables
p_numeric_histograms <- data_clean |>
  select(where(is.numeric), -latitude, -longitude) |>  # Drop lat/lon if you don't want them
  pivot_longer(cols = everything(), names_to = "Variable", values_to = "Value") |>  # New tidyverse version
  ggplot(aes(x = Value)) + 
  geom_histogram(fill = "#1B9E77", bins = 30) + 
  facet_wrap(~Variable, scales = "free", ncol = 3) +
  bengtegard_theme() +
  labs(x = "Value", y = "Frequency")

# Save the plot
ggsave(
  filename = "reports/figures/numeric_variables_histograms.png",
  plot = p_numeric_histograms,
  width = 12, height = 10
)
