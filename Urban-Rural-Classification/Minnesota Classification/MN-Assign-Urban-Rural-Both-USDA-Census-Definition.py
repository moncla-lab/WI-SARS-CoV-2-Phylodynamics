# This imports the Metadata
# I named the given test file "TEST-Official-Metadata-MN.csv" for an example
# Change the csv name to reflect what the metadate file is called
import pandas
df = pandas.read_csv('TEST-Official-Metadata-MN.csv',dtype=object)
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
# With the Wisconsin metadata, some samples did not have a Census Tract number, which is why this is necessary to show that some samples will remain unassigned
# Thus, this is not necessary if all your samples have a Census Tract Number
# This also provides clarification for the blank values
def assigned_or_unassigned(row):
    
    # This is testing the following: if census_tract is Nan; if not, there is a confirmed rural/urban classification
    if pandas.notna(row['census_tract']) and any(char.isdigit() for char in str(row['census_tract'])):
        print('Assigned')
        return 'Assigned'
    else:
        print('Unassigned')
        return 'Unassigned'

df['Assigned-or-Unassigned-USDA-Classification'] = df.apply(assigned_or_unassigned, axis=1)




# Here we read in the file from the USDA classification
# I titled the RUCA file as "MN-RUCA-Definitions"
ruca = pandas.read_csv('MN-RUCA-Definitions.csv',dtype=object)




# Merge the data from both files
# We are matching the values from the 11 digit census_tract with the 11 digit Total-FIPS-Code from the USDA
# See the specified column names from the example in Git
usda_merged_df = pandas.merge(df, ruca, left_on='census_tract', right_on='Total-FIPS-Code', how='left')

# This prevents Unassigned values from being dropped
usda_merged_df.fillna(value={'column_name_in_ruca': 'Unassigned'}, inplace=True)

# This removes NaN values
usda_merged_df = usda_merged_df.replace(np.nan, '')




# This creates a new file that I titled "MN-Midwest-Sars-Cov-2-ASSIGNED-Metadata"
# This only defines Urban/Rural according to the USDA definition
usda_merged_df.to_csv('MN-Midwest-Sars-Cov-2-ASSIGNED-Metadata.csv')




# This creates a new column that categorizes urban or rural based on USDA data
# The function also determines Urban or Rural classification
file_path = 'MN-Midwest-Sars-Cov-2-ASSIGNED-Metadata.csv'
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
census = pandas.read_csv('NHGIS-CensusTract-Data-MN.csv',dtype=object)




usda_merged_df = df




df['census_tract'] = df['census_tract'].astype(str)

# Merge based on different column names
merged_df = pandas.merge(df, census, left_on='census_tract', right_on='GEOCODE', how='left')

#This prevents Unassigned values from being dropped
merged_df['GEOCODE'].fillna(value='Unassigned', inplace=True)

#This removes NaN values
merged_df.replace(np.nan, '', inplace=True)




merged_df.to_csv('MN-Combined-Assigned-Metadata.csv')




# This creates a new column that vaugly categorizes urban or rural based on Census data

file_path = 'MN-Combined-Assigned-Metadata.csv'
df = pandas.read_csv(file_path)

df['Urban-or-Rural-Census-Classification'] = ''

# Define conditions and update the 'Urban_or_Rural' column
df.loc[(df['UrbanThreshold'] > 50) & (df['RuralThreshold'] < 50), 'Urban_or_Rural'] = 'Urban'
df.loc[(df['RuralThreshold'] > 50) & (df['UrbanThreshold'] < 50), 'Urban_or_Rural'] = 'Rural'

#This removes NaN values
df = df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)




# Further clean up column headers, removing spaces and other punctuation 
df.columns = df.columns.str.replace(r'[\(\)]', '').str.replace(r'[\s\W]', '_', regex=True)
# Further clean up column headers, removing spaces and other punctuation 
df = df.rename(columns={'Secondary RUCA Code, 2010 (see errata)': 'Secondary RUCA Code 2010', 
                        'Land Area (square miles), 2010' : 'Land Area sq miles 2010', 
                        'Population Density (per square mile), 2010' : 'Pop Density per sq mile 2010'
                       })
df.columns = df.columns.str.replace(r'[\(\)]', '').str.replace(r'[\s\W]', '_', regex=True)

df.to_csv(file_path, index=False)

df