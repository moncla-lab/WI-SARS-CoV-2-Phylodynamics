# This imports the Metadata
# Metadata combines both results from the USDA portion of the script and the Census portion of the script
# This script sorts the data as matches or mismatches in their respective definitions
# It also sorts the data for better analysis
import pandas
df = pandas.read_csv('Git-Match-Mismatch-USDA-Census-Combination.csv',dtype=object)
import numpy as np  # Import numpy for NaN representation
df = df.replace(np.nan, '')



# This creates a new column based on matching or mismatching Urban and Rural Classifications
def classify_match(row):
    usda_classification = row["Urban-or-Rural-USDA-Classification"]
    census_classification = row["Urban-or-Rural-CENSUS-Classification"]

    if pandas.isna(census_classification):
        return "Unknown"
    elif usda_classification == "Urban" and census_classification == "Urban":
        return "Match"
    elif usda_classification == "Rural" and census_classification == "Rural":
        return "Match"
    else:
        return "Mismatch"

df["Match/Mismatch"] = df.apply(classify_match, axis=1)



# This sorts the data to place the matches first and the mismatches last based on the new column
df.sort_values(by=["Match/Mismatch", "Urban-or-Rural-USDA-Classification", "UrbanThreshold"],
               inplace=True, ascending=[True, False, True], na_position="last")



# This writes the updated DataFrame back to the CSV file
df.to_csv("Complete-Match-Mismatch-Data.csv", index=False)

df




