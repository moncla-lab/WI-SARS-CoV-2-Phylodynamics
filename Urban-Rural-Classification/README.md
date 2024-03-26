## How to use the scripts:

The script "Assign-Urban-Rural-Both-USDA-Census-Definition.py" assigns urban and rural categories to Census Tracts utilizing both definitions from the Census and the USDA. To run this script, make sure you have the "RUCA-Definitions.csv" file (found in the USDA Definition folder) AND the "NHGIS-CensusTract-Data-WI.csv" file (found in the Census Definition folder) downloaded to your computer. The combined script has an argument parser to specify what the metadata file is titled as, but for the script to run, the metadata, RUCA codes, and NHGIS statistics must be downloaded to your computer for the script to read-in the files. The same instructions for downloading RUCA codes and NHGIS statistics apply to the python scrips for assigning distinctions with the USDA definition and the Census definition, respectively. Once the script is applied using python, it should output a csv file with the applied urban/rural disctinctions in a separate column for each definition. See the folder "Match Mismatch Analysis" for further data on how the definitions differ for our metadata.



## Data Contextualization

The purpose of this repository is to assign metadata from the Midwest Sars Cov2 Project to urban and rural categories. These assignments are based on definitions from the USDA and the US Census, which are different. At our disposal, we have metadata on Wisconsin residents’ SARS-Cov-2 strains. This data includes Zip codes, County FIPS codes, and Census Tracts. We hypothesize that urban centers are key sources of COVID transmission; we are also interested in looking at fluctuations with rural areas. The overall goal is to analyze different strains in midwestern populations based on geographic location. This repository, however, is to sort each strain into urban and rural distinctions for further analysis on epidemiologic and geographic levels. To do so, this repository uses a script in Python and the various urban/rural definitions according to the Census and the USDA. This merge between what the Census/USDA data assigns and the metadata we have is specifically done using a python script in order to work with the data on a large scale and apply the script to other metadata files in the future.

Sometimes the definitions that the Census gives us can be confusing and arbitrary. To begin simply defining the problem, here are some simple definitions:

Census Tracts: boundaries delineated with an intention of being stable between many census surveys. They follow permanent features in the landscape and are commonly used by statisticians and policy makers. The Metadata we have contains Census Tract codes, which is useful in analyzing our Metadata.

Census Block Groups: smaller than Census Tracts because they are deviations from Census Tracts that contain a collection of Census Blocks.

Census Blocks: the smallest geographic areas for which the Census Bureau collects information; they are formed by streets, roads, railroads, streams, and other bodies of water.

We began to start with the Census data on Urban/Rural distinctions and could only find the percentage of people living in “Urban” and “Rural” areas and how many Urban/Rural blocks were found in each county. However, this did not specify what Census Blocks and Tracts were actually Urban or Rural. Turning to the USDA definition, this categorization became more clear.

The USDA defines urban and rural areas based on commuting patterns and population, while the Census only defines these areas based on population. Building upon the urban-rural definition, the USDA developed sub-county classifications that more accurately delineate different levels of rurality and address program eligibility concerns using Census Tracts and County (Federal Information Processing Standard) FIPS Codes.

Most importantly, our metadata is specified based on Census Tracts and FIPS Codes.

By taking the County FIPS code, a pad of 0-3 zeros, and the Census Tract Number for each Census Block, we can get a specified FIPS code that corresponds to the USDA RUCA classification for Urban/Rural. For example, if the County FIPS code is 55079 and the Census Tract number is 304, the specified FIPS code is 55079000304. According to the USDA, the primary and secondary RUCA codes for this 11 digit number are 1, meaning this Census Block is a Metropolitan Area with primary flow within the urbanized area. This 11 digit number corresponds to primary and secondary RUCA codes described by the USDA for all Census Tracts and FIPS Codes. RUCA Codes classify U.S. Census Tracts using measures of population density, urbanization, and daily commuting. In simpler terms, numbers 1-8 constitute “Urban” while numbers 9-10 constitute “Rural”.

However, in order to still take into account the definition that the US Census provides, we are using data provided by NHGIS to run a similar script and determine an alternative urban/rural distinction.

In this repository, there are folders separated into the USDA definition, the Census definition, and a test script for more clarity with only 10 strains. I have also included a short presentation to explain this process and these definitions more clearly. Files that start with "Git" indicate they are specifically published in the repository on Github WITHOUT the GISAID strain name. Each csv or excel file simply has "strain 1, strain 2, etc".
