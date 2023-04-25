##### Description #####

The excel file gisaidavailable_sequences.xlsx contains all available data from GISAID filtered using the criteria listed below between 2020-01-01 to 2023-03-01. Each sheet contains a comment in cell A1 to communicate the purpose of that sheet and additional information.

The GISAID metadata was collected through the EpiCoV search. The fields were filtered as follows:

	Location, "North America/USA/Wisconsin"
	Text Search, "County"

	Boxes checked:
	Complete, High coverage, Collection date complete


This data was then passed through a python script to count the number of sequences available by county.

Population data found in this file was collected from the US Census Bureau's 2020 Census.

##### Credits #####

GISAID, https://gisaid.org/
US Census Bureau, 2020 Population Census, https://data.census.gov/

