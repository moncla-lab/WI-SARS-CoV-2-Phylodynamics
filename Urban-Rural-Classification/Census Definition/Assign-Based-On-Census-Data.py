# This imports the Metadata
# I titled the Metadata file as "Official-Metadata"
import pandas
df = pandas.read_csv('Official-Metadata.csv',dtype=object)
import numpy as np  # Import numpy for NaN representation
df = df.replace(np.nan, '')



# This creates a new column of assigned or unassigned USDA urban/rural classifications
# This essentially provides clarification for the blank values
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



# Here we read in the file from the CENSUS classification
import pandas
census = pandas.read_csv('NHGIS-CensusTract-Data-WI.csv',dtype=object)



df['State-County-TractFIPSCode'] = df['State-County-TractFIPSCode'].astype('int64')

# Merge based on different column names
merged_df = pandas.merge(df, census, left_on='State-County-TractFIPSCode', right_on='GEOCODE', how='left')

#This prevents Unassigned values from being dropped
merged_df['GEOCODE'].fillna(value='Unassigned', inplace=True)

#This removes NaN values
merged_df.replace(np.nan, '', inplace=True)



merged_df.to_csv('Census-Assigned-Metadata.csv')



#This creates a new column that vaugly categorizes urban or rural based on USDA data
# Function to determine Urban or Rural classification
file_path = 'Census-Assigned-Metadata.csv'
df = pandas.read_csv(file_path)

df['Urban_or_Rural'] = ''

# Define conditions and update the 'Urban_or_Rural' column
df.loc[(df['UrbanThreshold'] > 50) & (df['RuralThreshold'] < 50), 'Urban_or_Rural'] = 'Urban'
df.loc[(df['RuralThreshold'] > 50) & (df['UrbanThreshold'] < 50), 'Urban_or_Rural'] = 'Rural'

#This removes NaN values
df = df.replace(np.nan, '')

# Save the modified DataFrame back to the CSV file
df.to_csv(file_path, index=False)

df