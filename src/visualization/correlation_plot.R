# Import necessary libraries
library(tidyverse)
library(corrplot)

# Import the data
data_regression <- read_csv("data/interim/data_regression.csv")

# Calculate the correlation matrix for numeric variables
cor_matrix <- data_regression |>
  select(where(is.numeric)) |>
  cor() # calculate correlation

# Order by house_price correlation
ordered_vars <- names(sort(cor_matrix[, "house_price"], decreasing = TRUE))

# Reorder the correlation matrix
cor_matrix <- cor_matrix[ordered_vars, ordered_vars]

# Save plot
png(
  filename = "reports/figures/correlation_matrix.png",
  width = 1000, height = 800
)

# Plot correlation matrix using corrplot
corrplot::corrplot(cor_matrix,
  method = "color", type = "upper",
  addCoef.col = "black", number.cex = 0.7, tl.cex = 0.8,
  tl.col = "black", diag = FALSE
)

dev.off()
