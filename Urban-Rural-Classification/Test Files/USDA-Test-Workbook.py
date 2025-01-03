#This imports the Metadata
import pandas
df = pandas.read_csv('Test-10-Strains.csv',dtype=object)
import numpy as np  # Import numpy for NaN representation
df = df.replace(np.nan, '')

df



# This creates a new column of assigned or unassigned USDA urban/rural classifications
# Essentially provides clarification for the blank values
def assigned_or_unassigned(row):
    
    # This is testing the following: if CountyFIPS is Nan; if not, there is a confirmed rural/urban classification
    if pandas.notna(row['CountyFIPS']) and any(char.isdigit() for char in str(row['CountyFIPS'])):
        print('Assigned')
        return 'Assigned'
    else:
        print('Unassigned')
        return 'Unassigned'

df['Assigned-or-Unassigned-USDA-Classification'] = df.apply(assigned_or_unassigned, axis=1)

df



# This adds zeros to CensusTract values to make them all six digits long
# It also prevents NaN values from being shown
def add_zeros(value):
    if pandas.notna(value):
        return str(value).zfill(6)
    else:
        return ''

# This applies the function to all columns in the DataFrame
df['CensusTract'] = df['CensusTract'].apply(add_zeros)

df



# This defines a custom function to combine columns
def combine_columns(row):
    return str(row['CountyFIPS']) + row['CensusTract']

# Apply the custom function to create a new column
df['State-County-TractFIPSCode'] = df.apply(combine_columns, axis=1)

df



# Here we read in the file from the USDA classification
ruca = pandas.read_csv('RUCA-Definitions.csv',dtype=object)

ruca



# Merge based on different column names
merged_df = pandas.merge(df, ruca, left_on='State-County-TractFIPSCode', right_on='Total-FIPS-Code', how='left')

#This prevents Unassigned values from being dropped
merged_df.fillna(value={'column_name_in_ruca': 'Unassigned'}, inplace=True)

#This removes NaN values
merged_df = merged_df.replace(np.nan, '')

merged_df



merged_df.to_csv('Assigned-Test-10-Strains.csv')



#This creates a new column that vaugly categorizes urban or rural based on USDA data
# Function to determine Urban or Rural classification
file_path = 'Assigned-Test-10-Strains.csv'
df = pandas.read_csv(file_path)

def urban_or_rural_classification(row):
    primary_ruca_code = row['Primary RUCA Code 2010']
    
    if primary_ruca_code in [1, 2, 3, 4, 5, 6, 7]:
        return 'Urban'
    elif primary_ruca_code in [8, 9, 10]:
        return 'Rural'
    else:
        return 'Unknown'

# Create the new column
df['Urban-or-Rural-USDA-Classification'] = df.apply(urban_or_rural_classification, axis=1)

#This removes NaN values
df = df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)

df