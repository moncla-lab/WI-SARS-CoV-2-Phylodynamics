#!/usr/bin/env python3

# This imports the Metadata
# I titled the Metadata file as "Official-Metadata"
import pandas
df = pandas.read_csv('Official-Metadata.csv',dtype=object)
import numpy as np  # Import numpy for NaN representation
df = df.replace(np.nan, '')




import argparse
parser = argparse.ArgumentParser()

parser.add_argument('--metadata', type=str, help='Metadata file output from augur parse')
parser.add_argument('--ruca_codes', type=str, help='RUCA Classification from USDA Standards')

args = parser.parse_args()
metadata_file = args.metadata
ruca_file = args.ruca_codes




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
# I titled the RUCA file as "RUCA-Definitions"
ruca = pandas.read_csv('RUCA-Definitions.csv',dtype=object)




# Merge based on different column names
# See the specified column names from the example in Git
merged_df = pandas.merge(df, ruca, left_on='State-County-TractFIPSCode', right_on='Total-FIPS-Code', how='left')

# This prevents Unassigned values from being dropped
merged_df.fillna(value={'column_name_in_ruca': 'Unassigned'}, inplace=True)

# This removes NaN values
merged_df = merged_df.replace(np.nan, '')




# This creates a new column that vaugly categorizes urban or rural based on USDA data
# The function also determines Urban or Rural classification
def urban_or_rural_classification(row):
    primary_ruca_code = row['Primary RUCA Code 2010']
    
    if primary_ruca_code in [1, 2, 3, 4, 5, 6, 7,8]:
        return 'Urban'
    elif primary_ruca_code in [9, 10]:
        return 'Rural'
    else:
        return 'Unknown'

# Create the new column
merged_df['Urban-or-Rural-USDA-Classification'] = merged_df.apply(urban_or_rural_classification, axis=1)

# This removes NaN values
merged_df = merged_df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
merged_df.to_csv(file_path, index=False)




# Here we read in the file from the CENSUS classification
import pandas
census = pandas.read_csv('NHGIS-CensusTract-Data-WI.csv',dtype=object)



merged_df['State-County-TractFIPSCode'] = merged_df['State-County-TractFIPSCode'].astype('int64')

# Merge based on different column names
new_merged_df = pandas.merge(merged_df, census, left_on='State-County-TractFIPSCode', right_on='GEOCODE', how='left')

# This prevents Unassigned values from being dropped
new_merged_df['GEOCODE'].fillna(value='Unassigned', inplace=True)

# This removes NaN values
new_merged_df.replace(np.nan, '', inplace=True)



# This creates a new column that vaugly categorizes urban or rural based on USDA data
# Function to determine Urban or Rural classification

new_merged_df = df
df['Urban_or_Rural'] = ''

# Define conditions and update the 'Urban_or_Rural' column
df.loc[(df['UrbanThreshold'] > 50) & (df['RuralThreshold'] < 50), 'Urban_or_Rural'] = 'Urban'
df.loc[(df['RuralThreshold'] > 50) & (df['UrbanThreshold'] < 50), 'Urban_or_Rural'] = 'Rural'

# This removes NaN values
df = df.replace(np.nan, '')

# Further clean up column headers, removing spaces and other punctuation 

df = df.rename(columns={'Secondary RUCA Code, 2010 (see errata)': 'Secondary RUCA Code 2010', 
                        'Land Area (square miles), 2010' : 'Land Area sq miles 2010', 
                        'Population Density (per square mile), 2010' : 'Pop Density per sq mile 2010'
                       })
df.columns = df.columns.str.replace(r'[\(\)]', '').str.replace(r'[\s\W]', '_', regex=True)

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)



# Convert to a csv file
merged_df.to_csv('Combined-Assigned-Metadata.csv')

