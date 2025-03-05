# Urban Climate Risk Analysis

The Urban Climate Risk Analysis (UCRA) is a product of the City Resilience Program at the World Bank, which provides a rapid hazard and climate resilience assessment to multiple cities within a country of interest.
It mobilizes a range of global datasets on hazards, climate, and the built environment to derive high-level conclusions on the exposure and resilience of urban areas.
This repository contains the code needed to transform the raw data into city-level raster and vector files, as well as visualizations of summary statistics.
The Match Map Style toolbox (ArcMap) is needed separately to create city-level maps.
The background research and written analysis are also performed separately to culminate in a final report.

## Code Overview

The data processing for UCRA uses both Python and R.
The code is organized thematically into Jupyter Notebooks (for Python) and R scripts to allow for more modular use of this repo.

### Jupyter Notebooks (Python)

The Jupyter Notebooks are numbered to roughly indicate their sequencing in the data processing pipeline, based on the time and complexity required to process the corresponding data.
- The 00s notebooks are for setting up the files.
- The 10s notebooks are for more time-consuming raster data processing, such as ones that involve batch downloading or raster projecting.
- The 20s notebooks are for NetCDF data processing.
- The 30s notebooks are for data that require minimal, almost instant processing.
- The 40s notebooks are for statistical processing, often derived from the raster outputs of previous notebooks (10s - 30s). Note that the #41 notebook needs to be run in the arcpy environment (e.g., ArcGIS Pro).
- The 50s notebooks are for data sharing, as requested by task teams, or any post-delivery analytical follow-up.

Technically, the 10s - 30s notebooks can be run in any order, since they are mutually independent.
However, they are organized as such to reflect the estimated processing time required.
The 10s notebooks may take longer to run and should ideally be started earlier, and the 20s and 30s notebooks can be run while the 10s notebooks are under way.

### R Scripts

The names of R scripts are self-explanatory. Their sequencing will be indicated in the last section of step-by-step instructions.

## Required Global Datasets

Before commencing the data processing for any country, have the following global datasets downloaded on local computer:

- Global 1-km Downscaled Urban Land Extent Projection and Base Year Grids by SSP Scenarios, v1 (2000 – 2100) 
    - https://sedac.ciesin.columbia.edu/data/set/ssp-1-km-downscaled-urban-land-extent-projection-base-year-ssp-2000-2100
    - Download GeoTIFF for the SSPs selected for the UCRA
- Climate Change Knowledge Portal
    - https://climateknowledgeportal.worldbank.org/country/congo-dem-rep/climate-data-projections
    - The standard set of variables include:
        - Mean-Temperature
        - Precipitation
        - Maximum of Daily Max-Temperature
        - Number of Hot Days (Tmax > 35°C)
        - Number of Tropical Nights (T-min > 26°C)
        - Warm Spell Duration Index
        - Annual SPEI Drought Index
        - Days with Precipitation >20mm
        - Days with Precipitation >50mm
        - Max Number of Consecutive Dry Days
        - Precipitation amount during wettest days
    - Download for the SSPs and time period(s) selected for the UCRA
    - The "model" selection should always be Multi-Model Ensemble, unless agreed on otherwise with the task team
    - For "calculation", download both "mean" and "anomaly" values whenever possible
- Fathom 3.0
- Global SPEI database
    - https://spei.csic.es/spei_database/#map_name=spei01#map_position=1451
    - Download NC (NetCDF) for the following time-scales: spei01, spei12, and spei48
- Global (GL) Annual PM2.5 Grids from MODIS, MISR and SeaWiFS Aerosol Optical Depth (AOD), v4.03 (1998 – 2019)
    - https://sedac.ciesin.columbia.edu/data/set/sdei-global-annual-gwr-pm2-5-modis-misr-seawifs-aod-v4-gl-03
    - Download all years
- Projecting global urban land expansion and heat island intensification through 2050
    - https://figshare.com/s/d696842e80e8b02e9c7a
    - Download both day and night temperatures for the SSPs selected for the UCRA
- Global Landslide Hazard Map
    - https://datacatalog.worldbank.org/search/dataset/0037584
    - Download the "Global landslide hazard map - Rainfall trigger (1980-2018, median) - COG" GeoTIFF
- GDO GRACE Total Water Storage Anomaly (version 1.1.0)
    - https://data.jrc.ec.europa.eu/dataset/0fd62e28-241f-472c-8966-98744920e181
    - Download the GeoTIFF
- World Bank official country shapefile
    - https://worldbankgroup-my.sharepoint.com/:f:/g/personal/rsu_worldbank_org/EnuWm-JUTOZJikymjzzp3C8BipQfdUPU8WO1eXf7W-ZUsg?e=EyNIoT

In the Jupyter Notebooks, where the raw data are read and processed, update the file path to these downloaded datasets where necessary.

## Other Required Inputs

- City map templates, using the city of Matadi as an example
    - https://worldbankgroup-my.sharepoint.com/:f:/g/personal/rsu_worldbank_org/EvM3NaDQ1U1NhKafkVchmd8B00kVF0C-vhm9aOF6w1IguQ?e=eupyYe
- Country-level drought map templates, using DRC as an example
    - https://worldbankgroup-my.sharepoint.com/:f:/g/personal/rsu_worldbank_org/EpZZYNgmxb1PiohdmfX2E-YBj5MrVdCDP8j42UY2ooNXVA?e=SkylKk

## Steps

These are all the steps required to provide comprehensive inputs to a full UCRA report, not just the data processing component.
Therefore, some of the steps involve tools and resources beyond this repo.  

**It is crucial to follow the steps closely, as the codes are designed to run seamlessly within a rigid file structure and setup.**

1. Create a directory named after the country of interest (e.g., "DRC", "Sri Lanka"). This will be the working directory of the repo.
1. Clone the repo into the working directory. All the notebooks and scripts should be in the working directory with no subdirectories.
1. Create an ArcGIS Pro project in this directory, without creating a new subdirectory (i.e., the ArcGIS Pro project should be `./*.aprx`).
1. Run the notebook 00_setup steps 1-6.
1. Run the 10s notebooks.
1. While the 10s notebooks are running, run the Google Earth Engine scripts and download all raster outputs into `./output/GEE`.
Typically, the only GEE script needed for a standard UCRA is summer surface temperature: https://code.earthengine.google.com/dc803e30d92f447854b04f690065efdc.
1. While the GEE scripts are running, download Fathom data into its own subdirectory: `./data/Fathom`, which should in turn have at least the following subdirectories: `fluvial_undefended` and `pluvial`.
1. Run the 20s notebooks.
1. Run the 30s notebooks.
1. Run steps 7-8 of 00_setup notebook.
1. Run Match Map Style toolbox in ArcMap to produce maps for each city.
Within each city folder, all the data should have been stored in the `data` subfolder and the `maps` subfolder should be designated as the map template folder.
To get UTM projection for each city, consult `./centroids.csv`.
Note that there are two maps that require manual fixes each time.
First, the air quality map has incorrect binnings: there should be 8 bins, as listed in the legend, rather than 7, which is the default output of the toolbox.
Second, the landslide map's legend needs to be formatted to show 3 significant digits (or more if necessary).
1. While the toolbox is running, run the 40s notebooks.
Note that 41_stats_arcpy needs to be run in the ArcGIS Pro project (or another arcpy environment).
1. Once the toolbox finishes running, run step 9 of 00_setup notebook and run the "Share maps" and "Share stats" parts of the 50_share_data notebook. If the team asks for raw data, then also run the "Share data files" part, though pay attention to data agreements and avoid sharing proprietary data without permission. This concludes the Python portion of the analysis.
1. Create an R project and run each thematic R script as needed.
Note that for the two flood scripts, `flood_csv_processing.R` needs to be run prior to `flood_calc_and_plot.R`.
1. Finally, some miscellaneous mapping. 
In `./shapefile`, there should be two shapefiles: one for the country and one for all the city centroids (`centroids.shp`).
Add both to the ArcGIS Pro project.
Set basemap to Imagery and make sure to turn off any reference layers.
For the country shapefile, set the fill to no color and the outline to 3-pt white.
For the centroids shapefile, set the fill to white and the outline to 1-pt gray 50%. The size of the points should be 12 pt.
Additionally, turn on labeling for the centroids layer, with label field being "city".
In the Labeling menu's Text Symbol section, set the label style to "POI (Black 25% Transparency Halo)", which is under "Points of Interest" in the dropdown menu on the left.
Then, change the font to Helvetica and font size to 16 pt.
Zoom the map frame to the country layer and export the map to a 2956 width by 1766 height PNG.
1. Produce two maps for each of the following three drought variables: `twsan`, `spei12`, and `spei48`.
For each variable's time series, either eyeball the highest and lowest values from the corresponding plot, or sort the time series dataframe to find out the highest and lowest values.
THen, use ArcGIS Pro's "Make Multidimensional Raster Layer" tool to create raster files for the corresponding time period for `spei12` and `spei48`, so that they can be used directly for mapping.
Then, use the drought variables' map templates to create two maps for each variable and export to PNGs.
1. Upload `./maps`, `./plots`, and `./stats` to a shared folder and share them with colleagues, who will use these inputs to assemble the UCRA report.

## Contact

For inquiries, email rsu@worldbank.org.
