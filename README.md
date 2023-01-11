# 2022_typhoon_stability
Repository for data and code to reproduce typhoon soundscape analyses from Ross et al. (DATE, JOURNAL)

Data folder includes .rda data for acoustic indices, bird species detections, land cover in Okinawa, and processed stability values from these data. Data structure listed below.

R folder contains R script for cleaning the Acoustic index data, cleaning the bird species detection data, measuring stability of acoustic indices and bird species detections, and analysing the stability results. 

<a href="https://zenodo.org/badge/latestdoi/546414759"><img src="https://zenodo.org/badge/546414759.svg" alt="DOI"></a>

Data structure:

_2022_Species_detections.rda_



_Acoustic_indices.rda_



_all_landuse.rda_

- Landuse_1000 (wide-format dataframe of land use data per site, calculated at 1000m scale)
-- site_id: Name of field site.
-- Lat: Latitude of field site.
-- Long: Longitude of field site.
-- AGRICULTURE: Proportion of brown and green agriculture in 1000m buffer around field site.
-- FOREST: Proportion of forest in 1000m buffer around field site.
-- FRESHWATER: Proportion of freshwater in 1000m buffer around field site.
-- GRASS: Proportion of grass and scrubland in 1000m buffer around field site.
-- SAND: Proportion of dirt and sand in 1000m buffer around field site.
-- URBAN: Proportion of urban area in 1000m buffer around field site.
-- MISC: Proportion of remaining land use classifications in 1000m buffer around field site.
-- PC1: Principal Component Analysis Axis 1 value per field site.
-- PC2: Principal Component Analysis Axis 2 value per field site.

_Stability_Acoustic_Indices.rda_

- tidy.stability_AI (long-format tibble of acoustic index stability values per site)
-- Site_ID: Name of field site.
-- Index: Acoustic index, normalised difference soundscape index (NDSI), biophony (NDSI_Bio), or anthropophony (NDSI_Anthro).
-- Lat: Latitude of field site.
-- Long: Longitude of field site.
-- Land_PC1: Principal Component Analysis Axis 1 value per field site.
-- Land_PC2: Principal Component Analysis Axis 2 value per field site.
-- Landuse: Categoric land use based on PC clustering (Forest; Developed).
-- response_variable: Response variables for modeling, including pre-typhoon mean acoustic index values (Pre_mean), post-typhoon mean acoustic index values (Post_mean), pre-typhoon temporal variability (Pre_Var), post-typhoon temporal variability (Post_Var), resistance (Resist), and recovery time (Recov).
-- Stability: value for response_variable.

- wide.stability_AI (wide-format tibble of acoustic index stability values per site)
-- Site_ID: Name of field site.
-- Index: Acoustic index, normalised difference soundscape index (NDSI), biophony (NDSI_Bio), or anthropophony (NDSI_Anthro).
-- Pre_mean: Value of pre-typhoon mean acoustic index values. 
-- Post_mean: Value of post-typhoon mean acoustic index values. 
-- Pre_Var: Value of pre-typhoon temporal variability. 
-- Post_Var: Value of post-typhoon temporal variability. 
-- Resist: Value of resistance.
-- Recov: Value of recovery time.
-- Lat: Latitude of field site.
-- Long: Longitude of field site.
-- Land_PC1: Principal Component Analysis Axis 1 value per field site.
-- Land_PC2: Principal Component Analysis Axis 2 value per field site.
-- Landuse: Categoric land use based on PC clustering (Forest; Developed).

- tidy.spatial_AI (long-format tibble of acoustic index spatial variability data)
-- Date_Time: Date-time in YYYY-MM-DD hh:mm:ss.
-- Index: Acoustic index, normalised difference soundscape index (NDSI), biophony (NDSI_Bio), or anthropophony (NDSI_Anthro).
-- Period: Delineation of typhoons in study period (Pre-typhoon; Trami; Post-trami; Kong-rey; Post-typhoon).
-- response_group: Spatial variability is calculated across all 24 field sites (Total_Var), only the Forest sites (Forest_Var), or only the Developed sites (Developed_Var).
-- Stability: Value for response_group.

- wide.spatial_AI (wide-format tibble of acoustic index spatial variability data)
-- Date_Time: Date-time in YYYY-MM-DD hh:mm:ss.
-- Index: Acoustic index, normalised difference soundscape index (NDSI), biophony (NDSI_Bio), or anthropophony (NDSI_Anthro).
-- Total_Var: Value of spatial variability calculated across all 24 field sites.
-- Forest_Var: Value of spatial variability calculated across only the Forest sites.
-- Developed_Var: Value of spatial variability calculated across only the Developed sites.
-- Period: Delineation of typhoons in study period (Pre-typhoon; Trami; Post-trami; Kong-rey; Post-typhoon).

_Stability_Species_Detections.rda_

- tidy.stability_bird (long-format tibble of bird detection stability values per site)
-- Site_ID: Name of field site.
-- Species_ID: Latin species name.
-- Cutoff: Confidence threshold for bird detection results (0.5; 0.75; 0.9).
-- Lat: Latitude of field site.
-- Long: Longitude of field site.
-- Land_PC1: Principal Component Analysis Axis 1 value per field site.
-- Land_PC2: Principal Component Analysis Axis 2 value per field site.
-- Landuse: Categoric land use based on PC clustering (Forest; Developed).
-- response_variable: Response variables for modeling, including pre-typhoon mean daily detection (Pre_mean), post-typhoon mean daily detections (Post_mean), pre-typhoon temporal variability (Pre_Var), and post-typhoon temporal variability (Post_Var).
-- Stability: value for response_variable.

- wide.stability_birds (wide-format tibble of bird detection stability values per site)
-- Site_ID: Name of field site.
-- Species_ID: Latin species name.
-- Cutoff: Confidence threshold for bird detection results (0.5; 0.75; 0.9).
-- Pre_mean: Value of pre-typhoon mean daily detections. 
-- Post_mean: Value of post-typhoon mean daily detections. 
-- Pre_Var: Value of pre-typhoon temporal variability. 
-- Post_Var: Value of post-typhoon temporal variability. 
-- Lat: Latitude of field site.
-- Long: Longitude of field site.
-- Land_PC1: Principal Component Analysis Axis 1 value per field site.
-- Land_PC2: Principal Component Analysis Axis 2 value per field site.
-- Landuse: Categoric land use based on PC clustering (Forest; Developed).

- tidy.spatial_bird (long-format tibble of bird detection spatial variability data)
-- Date: Date in YYYY-MM-DD.
-- Species: Latin species name.
-- Period: Delineation of typhoons in study period (Pre-typhoon; Trami; Post-trami; Kong-rey; Post-typhoon).
-- response_group: Spatial variability is calculated across all 24 field sites (Total_Var), only the Forest sites (Forest_Var), or only the Developed sites (Developed_Var).
-- Stability: Value for response_group.

- wide.spatial_bird (wide-format tibble of bird detection spatial variability data)
-- Date: Date in YYYY-MM-DD.
-- Species: Latin species name.
-- Total_Var: Value of spatial variability calculated across all 24 field sites.
-- Forest_Var: Value of spatial variability calculated across only the Forest sites.
-- Developed_Var: Value of spatial variability calculated across only the Developed sites.
-- Period: Delineation of typhoons in study period (Pre-typhoon; Trami; Post-trami; Kong-rey; Post-typhoon).
