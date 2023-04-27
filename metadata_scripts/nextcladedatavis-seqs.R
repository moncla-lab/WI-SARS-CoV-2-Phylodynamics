library(ggplot2)
library(viridis)
library(dplyr)

# Lambodhar Damodaran
# 2023-04
# Script for visaulizations of nextclade data for SARS-COV-2 in Wisconsin
# Sequence data up to date: 04/15/2023

# nextclade results
nextcladeout <- read.csv("sequencedata/nextcladeout/nextclade.tsv", sep = '\t')


# GISAID sequence metadata
WI_loc_data <-  read.csv("WI_gisaidmeta-county-full.tsv", sep = '\t', header = TRUE)
df <- as.data.frame(WI_loc_data)
# make taxa names correspond to fasta file
df$taxid <- paste(df$Virus.name, df$Accession.ID, df$Collection.date_x, sep = "|" )

nextclade_subset <- nextcladeout[, c('seqName', 'Nextclade_pango', 'partiallyAliased','clade_who', 'clade')]
colnames(nextclade_subset)[1] <- "taxid"

#merge with filtered GISAID sequence 
nextclade_meta_merge <-  merge(df, nextclade_subset, by ="taxid")

# check GISAID lineage information vs Nextclade entry
clade_compare <- sum(nextclade_meta_merge$Lineage == nextclade_meta_merge$Nextclade_pango, na.rm = TRUE)
print( clade_compare)
count_na <- sum(is.na(nextclade_meta_merge$Nextclade_pango))
print(count_na)

#### Plots



# pango lineage (color alpha,delta,omicron)
pangolineagecounts_df <- as.data.frame(table(nextclade_meta_merge$Collection.date_x, nextclade_meta_merge$Nextclade_pango))
colnames(pangolineagecounts_df) <- c("Date", "Pango", "count")
pangolineagecounts_df$Date <- as.Date(pangolineagecounts_df$Date)


ggplot(pangolineagecounts_df, aes(x = Date, y = count, fill = ifelse(Pango == "B.1.1.7", "Alpha (B.1.1.7)",
                                                                    ifelse(Pango == "B.1.617.2", "Delta (B.1.617.2)",
                                                                           ifelse(Pango == "BA.1","Omicron (BA.1)", "Other"))))) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs in WI per Pango Lineage by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom") + labs(fill = "Pango Lineage")

# nextstrain clade

nextstrainlineagecounts_df <- as.data.frame(table(nextclade_meta_merge$Collection.date_x, nextclade_meta_merge$clade))
colnames(nextstrainlineagecounts_df) <- c("Date", "nextstrain", "count")
nextstrainlineagecounts_df$Date <- as.Date(nextstrainlineagecounts_df$Date)


ggplot(nextstrainlineagecounts_df, aes(x = Date, y = count, fill = nextstrain)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs in WI per Nextstrain Lineage by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom") + labs(fill = "Nextstrain Lineage")


# WHO clade


WHOlineagecounts_df <- as.data.frame(table(nextclade_meta_merge$Collection.date_x, nextclade_meta_merge$clade_who))
colnames(WHOlineagecounts_df) <- c("Date", "WHO", "count")
WHOlineagecounts_df$Date <- as.Date(WHOlineagecounts_df$Date)


ggplot(WHOlineagecounts_df, aes(x = Date, y = count, fill = WHO)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis_d(option = "plasma") +
  xlab("Date") +
  ylab("Counts") +
  ggtitle("# Seqs in WI per WHO Lineage by collection date:  2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal()  + theme(legend.position = "bottom") + labs(fill = "WHO Lineage")

