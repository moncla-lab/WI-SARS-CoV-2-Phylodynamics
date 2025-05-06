# Load required libraries
library(ggplot2)
library(scales)
library(dplyr)
library(readr)
library(ggbreak)  # For scale_y_break function

# Read the data
df <- read_csv("/Users/Wanting/Desktop/friedrich_lab/research_projects/BAA_diversity_compariosn/MN_data/lineage_group_fasta/distance_matrix_group/cluster_size_summary_04_15.csv")

# For clusters larger than 20, group them as "20+"
data_modified <- df %>%
  mutate(Cluster_Size_Group = ifelse(Cluster_Size > 20, "20+", as.character(Cluster_Size))) %>%
  group_by(Cluster_Size_Group) %>%
  summarize(Count = sum(Count)) %>%
  mutate(Cluster_Size_Group = factor(Cluster_Size_Group, 
                                     levels = c(as.character(1:20), "20+")))

# Add code to register the font if needed
# This ensures that Helvetica Neue is available to R
# Uncomment if you have font issues
# library(extrafont)
# font_import() # Run once to import fonts
# loadfonts()   # Load fonts for the session

# Create a plot with ggplot2 and use scale_y_break
p <- ggplot(data_modified, aes(x = Cluster_Size_Group, y = Count)) +
  geom_col(fill = "black", width = 0.7) +  # Width 0.7 for space between bars
  scale_y_break(c(7000, 30000), scales = 0.3) +
  scale_y_continuous(labels = comma, position = "left") +  # Ensure y-axis is only on left
  scale_y_continuous(labels = comma, position = "left", 
                     expand = c(0.02, 0)) +  # Control space between x-axis and bars
  scale_x_discrete(breaks = c("1", "5", "10", "15", "20+"),
                   expand = c(0.05, 0)) +  # Add space between y-axis and first bar
  labs(x = "Cluster size", y = "Number of clusters") +
  theme_classic() +  # Use classic theme for solid axis lines
  theme(
    text = element_text(family = "Helvetica Neue", size = 14),  # Set font family and increase size
    plot.title = element_text(family = "Helvetica Neue", size = 16, face = "bold"),
    axis.title = element_text(family = "Helvetica Neue", size = 14),
    axis.text = element_text(family = "Helvetica Neue", size = 12),
    panel.grid = element_blank(),  # Remove all grid lines
    panel.spacing = unit(0, "lines"),  # Remove panel spacing
    axis.line = element_line(color = "black", linewidth = 0.5),  # Solid axis lines
    axis.line.y.right = element_blank(),  # Remove right y-axis line
    axis.text.y.right = element_blank(),  # Remove right y-axis text
    axis.ticks.y.right = element_blank(),  # Remove right y-axis ticks
    axis.text.x = element_text(angle = 0, hjust = 0.5),
    axis.ticks = element_line(color = "black"),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )


print(p)

# Save the plot
#ggsave("cluster_size_distribution.png", p, width = 8, height = 6, dpi = 300)

