# WI-phylo-analysis-scripts

### The scripts in this directory were used in the broad scale county-level analyses of Wisconsin data.

#### A brief description of the scripts:

-  "1-Vax_sorter" calculates vaccination rates of each county in Wisconsin from a csv and counts the number of months each county has a vaccination rate above the median vaccination rate for all counties in Wisconsin.

-  "1.ADI-Sorting-using-FIPS-code-USCB" groups counties into "most advantaged", "disadvantaged", "middle", "advantaged", and "least disadvantaged" by the median ADI score associated with the FIPS code.

- "1.Adding_urban_rural_high_low_column_Nextstrain_metadata" adds a new column, "urb_rur_high_low" and assigns "urban" or "rural, "high" or "low" to each county within a Nextstrain metadata file.

- "1.m1m2_case_counts" calculates the case counts of confirmed or probable COVID-19 cases for each county in Wisconsin. The script then calculates the incidence using population data from the Census Bureau's 2020 Census.

- "1.m1m2_urb_rur_metadata_seqcounts" counts sequences for each county by two different urban and rural groupings. The first method of urban and rural grouping was taken from the Wisconsin Interactive Statistics on Health. The second method of grouping uses the 2013 Rural-Urban Continuum Codes from the USDA's Economic Research Service.

- "1.m1m2_urb_rur_metadata_seqcounts" counts the number of GISAID sequences available for both method 1 and method 2 of urban, rural groupings.

- "1.m1m2_urbrur_hilo_vaxgroup_seqcounts" counts the number of GISAID sequences available for both method 1 and method 2 of urban, rural and high, low vaccination groupings.

-  "2-Grouping_High_Low_Urb_Rur" uses the output from "1-Vax_sorter" to assign "Urban/Rural, High/Low" in a new column of a GISAID metadata file.
