library(ggplot2)
library(viridis)

# Lambodhar Damodaran
# 2023-04
# Script for visaulizations of metadata for SARS-COV-2 in Wisconsin
# Sequence data up to date: 04/15/2023

WI_loc_data <-  read.csv("WI-GISAID-county.tsv", sep = '\t', header = TRUE)
df <- as.data.frame(WI_loc_data)


#########
# Counts

# By county
ggplot(df, aes(County)) +
  geom_bar() +
  xlab("County") +
  ylab("Count") +
  geom_text(stat = "count", aes(label = ..count..), vjust = -0.5,size = 2) +
  ggtitle("# Seqs per WI County: 2020-03-01 to 2023-04-15") + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 


# By Urban rural
# As of 2023-04-15 - Rural = 9703, Urban = 32818 
table(WI_loc_data$urban_rural)

df$County


##########
## Number of seqs per county by date


county_counts_df <- as.data.frame(table(df$Collection.date, df$County))
colnames(county_counts_df) <- c("Date", "County", "count")
county_counts_df$Date <- as.Date(county_counts_df$Date)

# Create stacked bar plot of counts for each category by date
ggplot(county_counts_df, aes(x = Date, y = count, fill = County)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs per WI County by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom")

# color only dane and milwaukee

ggplot(county_counts_df, aes(x = Date, y = count, fill = ifelse(County == "dane", "Dane",
                                                                ifelse(County == "milwaukee", "Milwaukee", "other")))) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs per WI County by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom") + labs(fill = "County")


# by Urban/Rural 

urban_rural_counts_df <- as.data.frame(table(df$Collection.date, df$urban_rural))
colnames(urban_rural_counts_df) <- c("Date", "urban_rural", "count")
urban_rural_counts_df$Date <- as.Date(urban_rural_counts_df$Date)

ggplot(urban_rural_counts_df, aes(x = Date, y = count, fill = urban_rural)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs per WI urban/rural county by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom") + labs(fill = "Urban/Rural")





