# This imports the Metadata
# I titled the Metadata file as "Official-Metadata"
import pandas
df = pandas.read_csv('Official-Metadata.csv',dtype=object)
import numpy as np  # Import numpy for NaN representation
df = df.replace(np.nan, '')




import argparse
parser = argparse.ArgumentParser()

parser.add_argument('--metadata', type=str, help='Metadata file output from augur parse')
parser.add_argument('--ruca-codes', type=str, help='RUCA Classification from USDA Standards')

args = parser.parse_args()
metadata_file = args.metadata
ruca_file = args.ruca




# This creates a new column of assigned or unassigned USDA urban/rural classifications
# This also provides clarification for the blank values
def assigned_or_unassigned(row):
    
    # This is testing the following: if CountyFIPS is Nan; if not, there is a confirmed rural/urban classification
    if pandas.notna(row['CountyFIPS']) and any(char.isdigit() for char in str(row['CountyFIPS'])):
        print('Assigned')
        return 'Assigned'
    else:
        print('Unassigned')
        return 'Unassigned'

df['Assigned-or-Unassigned-USDA-Classification'] = df.apply(assigned_or_unassigned, axis=1)




# This adds zeros to CensusTract values to make them all six digits long
# It also prevents NaN values from being shown
def add_zeros(value):
    if pandas.notna(value):
        return str(value).zfill(6)
    else:
        return ''

# This applies the function to all columns in the DataFrame
df['CensusTract'] = df['CensusTract'].apply(add_zeros)




# This defines a custom function to combine columns
def combine_columns(row):
    return str(row['CountyFIPS']) + row['CensusTract']

# Apply the custom function to create a new column
df['State-County-TractFIPSCode'] = df.apply(combine_columns, axis=1)




# Here we read in the file from the USDA classification
# I titled the RUCA file as "WI-RUCA-Definitions"
ruca = pandas.read_csv('WI-RUCA-Definitions.csv',dtype=object)




# Merge based on different column names
# See the specified column names from the example in Git
usda_merged_df = pandas.merge(df, ruca, left_on='State-County-TractFIPSCode', right_on='Total-FIPS-Code', how='left')

# This prevents Unassigned values from being dropped
usda_merged_df.fillna(value={'column_name_in_ruca': 'Unassigned'}, inplace=True)

# This removes NaN values
usda_merged_df = usda_merged_df.replace(np.nan, '')




# This creates a new file that I titled "WI-Midwest-Sars-Cov-2-ASSIGNED-Metadata"
# This only defines Urban/Rural according to the USDA definition
usda_merged_df.to_csv('WI-Midwest-Sars-Cov-2-ASSIGNED-Metadata.csv')




# This creates a new column that categorizes urban or rural based on USDA data
# The function also determines Urban or Rural classification
file_path = 'WI-Midwest-Sars-Cov-2-ASSIGNED-Metadata.csv'
df = pandas.read_csv(file_path)
def urban_or_rural_classification(row):
    primary_ruca_code = row['Primary RUCA Code 2010']
    
    if primary_ruca_code in [1, 2, 3, 4, 5, 6, 7,8]:
        return 'Urban'
    elif primary_ruca_code in [9, 10]:
        return 'Rural'
    else:
        return 'Unknown'

# Create the new column
df['Urban-or-Rural-USDA-Classification'] = df.apply(urban_or_rural_classification, axis=1)

#This removes NaN values
df = df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)




# Here we read in the file from the CENSUS classification
import pandas
census = pandas.read_csv('NHGIS-CensusTract-Data-WI.csv',dtype=object)




usda_merged_df = df




df['State-County-TractFIPSCode'] = df['State-County-TractFIPSCode'].astype(str)

# Merge based on different column names
merged_df = pandas.merge(df, census, left_on='State-County-TractFIPSCode', right_on='GEOCODE', how='left')

#This prevents Unassigned values from being dropped
merged_df['GEOCODE'].fillna(value='Unassigned', inplace=True)

#This removes NaN values
merged_df.replace(np.nan, '', inplace=True)




merged_df.to_csv('WI-Combined-Assigned-Metadata.csv')




# This creates a new column that vaugly categorizes urban or rural based on USDA data
# Function to determine Urban or Rural classification

file_path = 'WI-Combined-Assigned-Metadata.csv'
df = pandas.read_csv(file_path)

df['NHGIS_Urban_or_Rural'] = ''

# Define conditions and update the 'Urban_or_Rural' column
df.loc[(df['UrbanThreshold'] > 50) & (df['RuralThreshold'] < 50), 'NHGIS_Urban_or_Rural'] = 'Urban'
df.loc[(df['RuralThreshold'] > 50) & (df['UrbanThreshold'] < 50), 'NHGIS_Urban_or_Rural'] = 'Rural'

#This removes NaN values
df = df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)



# Finally, read in the Latitude and Longitude data for Wisconsin for further centroid analysis
wisconsin = pandas.read_csv('Wisconsin-Lat-Long.csv',dtype=object)



# Convert the 'Total-FIPS-Code' column to integer type
df['State_County_TractFIPSCode'] = df['State_County_TractFIPSCode'].astype('int64')

# Convert the 'GEOID' column to integer type in the 'wisconsin' DataFrame
wisconsin['GEOID'] = wisconsin['GEOID'].astype('int64')

# Merge based on the corrected column names and data types
merged_lat_long_df = pandas.merge(df, wisconsin, left_on='State_County_TractFIPSCode', right_on='GEOID', how='left')

#This removes NaN values
merged_lat_long_df.replace(np.nan, '', inplace=True)




# Further clean up column headers, removing spaces and other punctuation 
merged_lat_long_df.columns = merged_lat_long_df.columns.str.replace(r'[\(\)]', '').str.replace(r'[\s\W]', '_', regex=True)
# Further clean up column headers, removing spaces and other punctuation 
merged_lat_long_df = merged_lat_long_df.rename(columns={'Secondary RUCA Code, 2010 (see errata)': 'Secondary RUCA Code 2010', 
                        'Land Area (square miles), 2010' : 'Land Area sq miles 2010', 
                        'Population Density (per square mile), 2010' : 'Pop Density per sq mile 2010'
                       })
merged_lat_long_df.columns = merged_lat_long_df.columns.str.replace(r'[\(\)]', '').str.replace(r'[\s\W]', '_', regex=True)


# I saved the final csv file with this name
merged_lat_long_df.to_csv('WI-Assigned-Metadata-Combined-Lat-Long.csv')




# This cleans out unnecessary columns that are no longer needed in the file and renames the cleaned version
csv_file_path = 'WI-Assigned-Metadata-Combined-Lat-Long.csv'

df = pandas.read_csv(csv_file_path)

columns_to_drop = [
    "Unnamed__0_1", "Unnamed__0", "State_County_TractFIPSCode", 
    "State_County_FIPS_Code", "Tract_Population__2010", 
    "Land_Area__square_miles___2010", 
    "Population_Density__per_square_mile___2010", "GEOID_x", 
    "COUNTYA", "TRACTA", "U7I001", "U7I002", "STATEFP", 
    "COUNTYFP", "TRACTCE", "GEOID_y", "NAME", "NAMELSAD", 
    "MTFCC", "FUNCSTAT", "ALAND", "AWATER"
]

df_cleaned = df.drop(columns=columns_to_drop)

output_file_path = 'WI-Assigned-Metadata-Cleaned.csv'

df_cleaned.to_csv(output_file_path, index=False)

print(f"Cleaned CSV saved as: {output_file_path}")
