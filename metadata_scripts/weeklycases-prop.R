library(dplyr)
library(lubridate)
library(tidyr)
library(ggplot2)
library(tidyverse)
library(ISOweek)
library(viridis)


# code to calculate the weekly cumulative cases 
# calculate the proportion a given counties cases are of the total casees for a given week


WI_county_data <- read.csv("WI-Incidence-data/COVID19-Historical-V2-CNTY.csv", header = TRUE)

# subset for data that we care about (county,date,POS_NEW_CONF (postive new cases that are confirmed))
df <- WI_county_data[, c('GEOName','Date', 'POS_NEW_CONF')]

df$Date_good <- mdy(df$Date)
df$year <- year(df$Date_good)

# get the CDC epi week
df <- df %>%
  mutate(week = epiweek(Date_good))

# standardize week-year
df$yearweek <- as.integer(paste0(df$year, sprintf("%02d", df$week)))
df <- arrange(df, yearweek)

df2 <- df %>%
  group_by(GEOName, yearweek) %>%
  summarize(cumul_cases = sum(POS_NEW_CONF)) %>%
  ungroup()


df2_wide <- df2 %>%
  pivot_wider(names_from = yearweek, values_from = cumul_cases)

# calculate proportion of cases of total for each county by week 
df_prop <- df2 %>%
  group_by(yearweek) %>%
  mutate(prop_cases = cumul_cases / sum(cumul_cases)) %>%
  ungroup()

df_prop[is.na(df_prop)] <- 0
df_prop <- df_prop %>%
  mutate(isoweek = str_replace(yearweek,
                               "^(\\d{4})(\\d{2})$",
                               "\\1-W\\2-1"),
         date = ISOweek::ISOweek2date(isoweek))

## visualizations of proportions 


# Create the plot with colored lines
ggplot(data = df_prop, aes(x = date, y = cumul_cases, color = GEOName)) +
  geom_line() + scale_colour_viridis_d() +
  xlab("Date") +
  ylab("Confirmed Cases") +
  ggtitle("Confirmed SARS-COV-2 cases by county: 2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal() + theme(legend.position = "bottom") + labs(fill = "County")



ggplot(data = df_prop, aes(x = date, 
                           y = cumul_cases, 
                           color = ifelse(GEOName == "Dane", "Dane",
                                      ifelse(GEOName == "Milwaukee", "Milwaukee",
                                         ifelse(GEOName == "Waukesha","Waukesha", "Other"))))) +
  geom_line() + scale_colour_viridis_d() +
  xlab("Date") +
  ylab("Confirmed Cases") +
  ggtitle("Confirmed SARS-COV-2 cases by county: 2020-03-01 to 2023-04-15") +
  scale_x_date(date_breaks = "3 months", date_labels = "%b %Y") +
  theme_minimal() + theme(legend.position = "bottom") + labs(fill = "County")


