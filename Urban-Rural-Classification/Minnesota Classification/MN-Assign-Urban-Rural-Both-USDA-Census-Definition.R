library(tidyverse)

# Define file paths
input_file <- 'TEST-Official-Metadata-MN.csv'
output_file <- 'MN-Combined-Assigned-Metadata.csv'

ruca_file <- 'MN-RUCA-Definitions.csv'
census_file <- 'NHGIS-CensusTract-Data-MN.csv'

# Start of script
df <- read_csv(input_file, col_types=cols(census_tract=col_character()))
ruca <- read_csv(ruca_file, col_types=cols('Total-FIPS-Code'=col_character()))
census <- read_csv(census_file, col_types=cols(
  'GEOCODE'=col_character(),
  'UrbanThreshold'=col_integer(),
  'RuralThreshold'=col_integer(),
))

df <- df |>
  mutate(`Assigned-or-Unassigned-USDA-Classification` = case_when(
    !is.na(census_tract) & str_detect(as.character(census_tract), "\\d") ~ "Assigned",
    TRUE ~ "Unassigned"
  )) |>
  left_join(ruca, by = c("census_tract" = "Total-FIPS-Code"), keep=TRUE) |>
  mutate(`Urban-or-Rural-USDA-Classification` = case_when(
    `Primary RUCA Code 2010` %in% 1:8 ~ "Urban",
    `Primary RUCA Code 2010` %in% 9:10 ~ "Rural",
    TRUE ~ "Unknown"
  )) |>
  left_join(census, by = c("census_tract" = "GEOCODE"), keep=TRUE) |>
  mutate(`Urban-or-Rural-Census-Classification` = case_when(
    UrbanThreshold > 50 & RuralThreshold < 50 ~ "Urban",
    RuralThreshold > 50 & UrbanThreshold < 50 ~ "Rural",
    TRUE ~ ""
  )) |>
  rename(
    `Secondary_RUCA_Code_2010` = `Secondary RUCA Code, 2010 (see errata)`,
    `Land_Area_sq_miles_2010` = `Land Area (square miles), 2010`,
    `Pop_Density_per_sq_mile_2010` = `Population Density (per square mile), 2010`
  ) %>%
  rename_with(~ str_replace_all(., "[\\(\\)]", "") %>% 
                str_replace_all("[\\s\\W]", "_"))

write_csv(df, output_file, na="")