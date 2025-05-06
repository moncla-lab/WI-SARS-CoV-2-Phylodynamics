pip install fiona geopandas xgboost gensim folium pyLDAvis descartes



import geopandas as gpd
import matplotlib.pyplot as plt
import pandas as pd

from shapely.geometry import Point

get_ipython().run_line_magic('matplotlib', 'inline')



# Read in state geometry file
state_df = gpd.read_file("https://datascience.quantecon.org/assets/data/cb_2016_us_state_5m.zip")
state_df.head()




# Apply geometry for state of interest
fig, gax = plt.subplots(figsize=(10, 10))
state_df.query("NAME == 'Wisconsin'").plot(ax=gax, edgecolor="black", color="white")



# Read in Census Tract geometries as a zip TIGER file
# This can be found from the Census TIGER file database with specifications of "Wisconsin", "Census Tract", and "2010" to match RUCA codes
tract_df = gpd.read_file("tl_2010_55_tract10.zip")



# Apply state geometry to tract geometries
fig, gax = plt.subplots(figsize=(10, 10))


state_df.query("NAME == 'Wisconsin'").plot(ax=gax, edgecolor="black", color="white")
tract_df.plot(ax=gax, edgecolor="black", color="white")



# Read in RUCA file from USDA specifications
ruca = pd.read_csv("RUCA-Definitions.csv", thousands=",")
ruca.head()



# For ruca DataFrame
if ruca["Total-FIPS-Code"].dtype == 'object':  # Check if the column contains string values
    ruca["Total-FIPS-Code"] = ruca["Total-FIPS-Code"].str.title()
    ruca["Total-FIPS-Code"] = ruca["Total-FIPS-Code"].str.strip()

# For tract_df DataFrame
if tract_df["GEOID10"].dtype == 'object':  # Check if the column contains string values
    tract_df["GEOID10"] = tract_df["GEOID10"].str.title()
    tract_df["GEOID10"] = tract_df["GEOID10"].str.strip()



# Merge data from RUCA codes and Tract geometries
tract_df['GEOID10'] = tract_df['GEOID10'].astype('int64')

res_w_tracts = tract_df.merge(ruca, left_on="GEOID10", right_on="Total-FIPS-Code", how="inner")



# Use subplots to apply merged information to the state and tract geometries
fig, gax = plt.subplots(figsize = (10,8))

# Plot the state
state_df[state_df['NAME'] == 'Wisconsin'].plot(ax = gax, edgecolor='black',color='white')

res_w_tracts.plot(
    ax=gax, edgecolor='black', column='Tract Population, 2010', legend=True, cmap='RdBu_r',
    vmin=500, vmax=8000)

# Add text 
gax.annotate('Tract Population',xy=(0.76, 0.06),  xycoords='figure fraction')

# I want the axis with long and lat but not necessary
#plt.axis('off')

plt.title('Wisconsin Tract Population')
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.savefig('WI-Tract-Population.png')



# Use subplots to apply merged information to the state and tract geometries
fig, gax = plt.subplots(figsize = (10,8))

# Plot the state
state_df[state_df['NAME'] == 'Wisconsin'].plot(ax = gax, edgecolor='black',color='white')

res_w_tracts.plot(
    ax=gax, edgecolor='black', column='Primary RUCA Code 2010', legend=True, cmap='RdBu_r',
    vmin=1, vmax=10)

# Add text 
gax.annotate('RUCA Classification',xy=(0.76, 0.06),  xycoords='figure fraction')

# I want the axis with long and lat but not necessary
#plt.axis('off')

plt.title('Wisconsin RUCA Code Map')
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.savefig('WI-RUCA-Map.png')



# Add a new column based on conditions
res_w_tracts['Numerical-Classification'] = res_w_tracts['Urban-or-Rural-USDA-Classification'].apply(lambda x: 1 if x == 'Urban' else (2 if x == 'Rural' else None))



# Use subplots to apply merged information to the state and tract geometries
fig, gax = plt.subplots(figsize = (10,8))

# Plot the state
state_df[state_df['NAME'] == 'Wisconsin'].plot(ax = gax, edgecolor='black', color='white')

res_w_tracts[res_w_tracts['Urban-or-Rural-USDA-Classification'] == 'Urban'].plot(ax=gax, edgecolor='black', color='navy')
res_w_tracts[res_w_tracts['Urban-or-Rural-USDA-Classification'] == 'Rural'].plot(ax=gax, edgecolor='black', color='crimson')

# I want the axis with long and lat but not necessary
#plt.axis('off')

plt.title('Wisconsin Urban or Rural RUCA Code Map')
plt.xlabel('Longitude')
plt.ylabel('Latitude')

plt.savefig('Simplified-WI-RUCA-Map.png')



from bokeh.io import output_notebook
from bokeh.plotting import figure, ColumnDataSource
from bokeh.io import output_notebook, show, output_file
from bokeh.plotting import figure
from bokeh.models import GeoJSONDataSource, LinearColorMapper, ColorBar, HoverTool
from bokeh.palettes import brewer
output_notebook()
import json
#Convert data to geojson for bokeh
wi_geojson=GeoJSONDataSource(geojson=res_w_tracts.to_json())




# Use Bokeh software to use hovertools over different tracts
color_mapper = LinearColorMapper(palette = brewer['PRGn'][10], low = 1, high = 10)
color_bar = ColorBar(color_mapper=color_mapper, label_standoff=8,width = 500, height = 20,
                     border_line_color='black',location = (0,0), orientation = 'horizontal')
hover = HoverTool(tooltips = [('Total FIPS Code','@GEOID10'),('Census Tract','@NAMELSAD10'),])
p = figure(title="Wisconsin RUCA Map", tools=[hover])
p.patches("xs","ys",source=wi_geojson,
          fill_color = {'field' :'Primary RUCA Code 2010', 'transform' : color_mapper})
p.add_layout(color_bar, 'below')
p.add_tools('reset')
p.add_tools('wheel_zoom')
p.add_tools('zoom_in')
p.add_tools('zoom_out')
p.add_tools('box_select')
p.add_tools('save')
p.add_tools('pan')



from bokeh.plotting import figure, output_file, save

# set output to static HTML file
output_file(filename="RUCA-Hover_Map.html", title="RUCA HTML file")

# create a new plot with a specific size
p = figure(sizing_mode="stretch_width", max_width=500, height=250)

# save the results to a file
save(p)
