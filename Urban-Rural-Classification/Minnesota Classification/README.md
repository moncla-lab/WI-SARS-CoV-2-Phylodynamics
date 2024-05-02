## How to use the scripts:

The script "MN-Assign-Urban-Rural-Both-USDA-Census-Definition.py" assigns urban and rural categories to Census Tracts utilizing both definitions from the Census and the USDA. 

To run this script:

1) Make sure you have the "MN-RUCA-Definitions.csv" file (found in the Minnesota Classification folder) AND the "NHGIS-CensusTract-Data-MN.csv" file (found in the Minnesota Classification folder) downloaded to your computer. The combined script has an argument parser to specify what the metadata file is titled as, but for the script to run, the metadata, RUCA codes, and NHGIS statistics must be downloaded to your computer for the script to read-in the files. Once the script is applied using python, it should output a csv file with the applied urban/rural disctinctions in a separate column for each definition.

2) The exact column name that MUST be in the metadata file is "census_tract" for the script to run. 

3) To call and run the script, be in the directory that all the files are downloaded to. 

4) Upon running the script, two csv files will be produced. One titled "MN-Midwest-Sars-Cov-2-ASSIGNED-Metadata.csv" matches the metadata to the USDA definition of urban/rural. The other titled "MN-Combined-Assigned-Metadata.csv" matches the metadata to both the USDA definition AND the Census definition. For more information about the different definitions, read below. 

5) The file "TEST-Official-Metadata-MN.csv" is what the starting metadata file should look like as an example. The file "MN-Combined-Assigned-Metadata.csv" is what the final output should look like.



## Data Contextualization

The purpose of this repository is to assign metadata from the Midwest Sars Cov2 Project to urban and rural categories. These assignments are based on definitions from the USDA and the US Census, which are different. At our disposal, we have metadata on Minnesota residents’ SARS-Cov-2 strains. This data includes Census Tracts. This repository uses a script in Python and the various urban/rural definitions according to the Census and the USDA. This merge between what the Census/USDA data assigns and the metadata we have is specifically done using a python script in order to work with the data on a large scale and apply the script to other metadata files in the future.

Sometimes the definitions that the Census gives us can be confusing and arbitrary. To begin simply defining the problem, here are some simple definitions:

Census Tracts: boundaries delineated with an intention of being stable between many census surveys. They follow permanent features in the landscape and are commonly used by statisticians and policy makers. The Metadata we have contains Census Tract codes, which is useful in analyzing our Metadata.

Census Block Groups: smaller than Census Tracts because they are deviations from Census Tracts that contain a collection of Census Blocks.

Census Blocks: the smallest geographic areas for which the Census Bureau collects information; they are formed by streets, roads, railroads, streams, and other bodies of water.

The USDA defines urban and rural areas based on commuting patterns and population, while the Census only defines these areas based on population. Building upon the urban-rural definition, the USDA developed sub-county classifications that more accurately delineate different levels of rurality and address program eligibility concerns using Census Tracts and County (Federal Information Processing Standard) FIPS Codes.

Most importantly, our metadata is specified based on Census Tracts.

By taking the Census Tract Number, we can get a specified 11 digit FIPS code that corresponds to the USDA RUCA classification for Urban/Rural. This 11 digit number corresponds to primary and secondary RUCA codes described by the USDA for all Census Tracts. RUCA Codes classify U.S. Census Tracts using measures of population density, urbanization, and daily commuting. In simpler terms, numbers 1-8 constitute “Urban” while numbers 9-10 constitute “Rural”.

However, in order to still take into account the definition that the US Census provides, we are using data provided by NHGIS to run a similar script and determine an alternative urban/rural distinction.

In this repository, there are folders separated into the USDA definition, the Census definition, and a test script for more clarity.
