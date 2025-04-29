library(ggplot2)

# Define background color, text color, and color palette for themes
BG_COLOR <- "#FFFFFA"
TEXT_COLOR <- "#0D5C63"
BAR_PALETTE <- c("#72B0AB", "#BCDDDC", "#FFEDD1", "#FDC1B4", "#FE9179", "#F1606C")
BAR_COLOR <- c("#D36A3F", "#1B9E77", "#5D69B1")
GRADIENT_COLORS <- c(
  "#3B4D57", "#3C5A63", "#3D6670", "#3E7480", "#3F8290",
  "#40869F", "#4191AE", "#429DBD", "#43A9CC", "#44B5DB"
)

# Custom theme function for ggplot2
bengtegard_theme <- function() {
  theme(
    # Title and subtitle
    plot.title = element_text(color = TEXT_COLOR, size = 16, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(color = TEXT_COLOR, size = 12, face = "plain", hjust = 0.5),
    plot.margin = margin(20, 20, 20, 20), # Adding margin for a better visual appearance

    # Axis titles
    axis.title.x = element_text(color = TEXT_COLOR, size = 14, face = "bold"),
    axis.title.y = element_text(color = TEXT_COLOR, size = 14, face = "bold"),

    # Axis tick labels
    axis.text.x = element_text(color = TEXT_COLOR, size = 10),
    axis.text.y = element_text(color = TEXT_COLOR, size = 10),

    # Legend settings
    legend.text = element_text(color = TEXT_COLOR),
    legend.title = element_text(color = TEXT_COLOR),
    legend.background = element_rect(fill = BG_COLOR),

    # Grid lines
    panel.grid.major = element_line(color = "lightgray", size = 0.5),
    panel.grid.minor = element_line(color = "lightgray", size = 0.3, linetype = "dotted"),

    # Background color and border
    plot.background = element_rect(fill = BG_COLOR, color = BG_COLOR),
    panel.background = element_rect(fill = BG_COLOR, color = BG_COLOR)
  )
}
