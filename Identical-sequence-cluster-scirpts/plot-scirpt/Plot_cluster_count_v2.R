# Load required libraries
library(ggplot2)
library(scales)
library(dplyr)
library(readr)

# Read the data
df <- read_csv("/Users/Wanting/Desktop/friedrich_lab/research_projects/BAA_diversity_compariosn/MN_data/lineage_group_fasta/distance_matrix_group/cluster_size_summary_04_15.csv")

# Create more granular cluster size grouping (3 through 20, then 20+)
data_modified <- df %>%
  filter(Cluster_Size >= 3) %>%  # Only include cluster size 3 and above
  mutate(Cluster_Size_Group = ifelse(Cluster_Size > 20, "20+", as.character(Cluster_Size))) %>%
  group_by(Cluster_Size_Group) %>%
  summarize(Count = sum(Count)) %>%
  # Create proper ordering for factor levels (3 through 20, then 20+)
  mutate(Cluster_Size_Group = factor(Cluster_Size_Group, 
                                     levels = c(as.character(3:20), "20+")))

# Create a plot with ggplot2 WITHOUT scale_y_break
p <- ggplot(data_modified, aes(x = Cluster_Size_Group, y = Count)) +
  geom_col(fill = "black", width = 0.7) +  # Width 0.7 for space between bars
  scale_y_continuous(labels = comma, position = "left", 
                     expand = c(0.02, 0)) +  # Control space between x-axis and bars
  # You may need to adjust this if you have many bars
  scale_x_discrete(expand = c(0.05, 0)) +  # Add space between y-axis and first bar
  # Add labels on top of bars
  geom_text(aes(label = comma(Count)), 
            position = position_dodge(width = 0.7),
            vjust = -0.5,  # Adjust this value to position labels
            size = 3.5,    # Adjust text size as needed
            family = "Helvetica Neue") +
  labs(x = "Cluster size", y = "Number of clusters") +
  theme_classic() +  # Use classic theme for solid axis lines
  theme(
    text = element_text(family = "Helvetica Neue", size = 14),
    plot.title = element_text(family = "Helvetica Neue", size = 16, face = "bold"),
    axis.title = element_text(family = "Helvetica Neue", size = 14),
    axis.text = element_text(family = "Helvetica Neue", size = 12),
    panel.grid = element_blank(),
    panel.spacing = unit(0, "lines"),
    axis.line = element_line(color = "black", linewidth = 0.5),
    axis.line.y.right = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.y.right = element_blank(),
    # Adjust the angle for better readability with many categories
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.ticks = element_line(color = "black"),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )

print(p)