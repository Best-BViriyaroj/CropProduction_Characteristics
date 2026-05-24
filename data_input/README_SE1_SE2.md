# Guide to Data Acquisition and Processing Scripts

This document provides instructions on how to use the R scripts to acquire and process the datasets for various environmental variables. The scripts are organized into folders, each corresponding to a specific variable.

The workflow is divided into two main parts for most variables:
- **Standard Element 1 (SE1):** Data Acquisition. This involves downloading the necessary raw data from external sources.
- **Standard Element 2 (SE2):** Data Processing. This involves running R scripts to process, harmonize, and analyze the raw data.

## Aridity Index

### Data Acquisition (`aridity_index/Aridity_Index_SE1.Rmd`)

1.  **Precipitation Data (MSWEP):**
    *   Request access and download the monthly precipitation data in NC format from [https://www.gloh2o.org](https://www.gloh2o.org).
2.  **Potential Evaporation Data (GLEAM):**
    *   Request access and download the potential evaporation data in NC format from [https://www.gleam.eu/#downloads](https://www.gleam.eu/#downloads) using an SFTP client like FileZilla or WinSCP.

### Data Processing (`aridity_index/Aridity_Index_SE2.Rmd`)

This script performs the following steps:
1.  Reads the monthly precipitation data from MSWEP.
2.  Reads the potential evaporation data from GLEAM.
3.  Calculates the aridity index (AI = P/PET).
4.  Resamples the data to a 5-arcminute resolution.
5.  Applies a log transformation to the aridity index values.
6.  Stacks the processed yearly data into a single file.

## Evaporation

### Data Acquisition (`evaporation/Evaporation_SE1.Rmd`)

*   Request access and download the evaporation data in NC format from [https://www.gleam.eu/#downloads](https://www.gleam.eu/#downloads) using an SFTP client.

### Data Processing (`evaporation/Evaporation_SE2.Rmd`)

This script performs the following steps:
1.  Reads the downloaded evaporation data in NC format.
2.  Converts the data to GeoTIFF format.
3.  Resamples the data to a 5-arcminute resolution and stacks it.

## Growing Degree Days (GDD)

### Data Acquisition (`growing_degree_days/GDD_SE1.Rmd`)

1.  **Temperature Data (MSWX):**
    *   Download the daily maximum and minimum temperature data from [https://www.gloh2o.org/mswx/](https://www.gloh2o.org/mswx/).
2.  **Crop Temperature Range:**
    *   The script uses the `LUIcube_cropBaseCutoffTemperature_v2.xlsx` file, which contains the base and cutoff temperatures for various crops.
3.  **Crop Masks (LUIcube):**
    *   The harvested net primary production data from Matej et al. 2025 is used to create weighted masks.

### Data Processing (`growing_degree_days/GDD_SE2.Rmd`)

This script performs the following steps:
1.  Calculates the fraction of harvested area for each crop.
2.  Calculates the annual Growing Degree Days (GDD) for each crop from 1992 to 2020, weighted by the crop fraction.
3.  Sums the GDD values across all crops for each year.
4.  Stacks the yearly GDD data into a single file.

## Nitrogen

### Data Acquisition and Processing (`nitrogen/Nitrogen_SE1_SE2.Rmd`)

This script downloads and processes total nitrogen data from SoilGrids. Since the data is static, the same values are used for all years (1992-2020).

The script performs the following steps:
1.  Downloads nitrogen data for three soil depths (0-5cm, 5-15cm, 15-30cm) directly at a 5-arcminute resolution.
2.  Calculates a weighted average for the 0-30cm depth.
3.  Projects the data to the correct CRS.
4.  Duplicates the single-year data into a 29-layer stack (1992-2020).

## Phosphorus

### Data Acquisition and Processing (`phosphorus/OlsenP_SE1_SE2.Rmd`)

This script processes plant-available phosphorus data. Since the data is static, the same values are used for all years (1992-2020).

1.  **Data Download:**
    *   Download the `OlsenP_5arcmin_mgkg.tif` file from [Figshare](https://figshare.com/articles/dataset/Global_Available_Soil_Phosphorus_Database/14241854).

2.  **Processing:**
    *   The script duplicates the single-layer raster into a 29-layer stack (1992-2020).

## Precipitation

### Data Acquisition (`precipitation/Precipitation_SE1.Rmd`)

*   Request access and download the monthly precipitation data in NC format from [https://www.gloh2o.org](https://www.gloh2o.org).

### Data Processing (`precipitation/Precipitation_SE2.Rmd`)

This script performs the following steps:
1.  Reads the downloaded monthly precipitation data in NC format.
2.  Aggregates the monthly data into annual totals.
3.  Converts the data to GeoTIFF format.
4.  Resamples the data to a 5-arcminute resolution and stacks it.

## Soil Moisture

### Data Acquisition (`soil_moisture/SoilMoisture_SE1.Rmd`)

*   Request access and download the root zone soil moisture data in NC format from [https://www.gleam.eu/#downloads](https://www.gleam.eu/#downloads) using an SFTP client.

### Data Processing (`soil_moisture/SoilMoisture_SE2.Rmd`)

This script performs the following steps:
1.  Reads the downloaded yearly soil moisture data in NC format.
2.  Resamples the data to a 5-arcminute resolution.
3.  Saves the processed data as GeoTIFF files.
4.  Stacks the yearly data into a single file.

## Soil Organic Carbon (SOC)

### Data Acquisition and Processing (`soil_organic_carbon/SOC_SE1_SE2.Rmd`)

This script downloads and processes soil organic carbon (SOC) data from SoilGrids. Since the data is static, the same values are used for all years (1992-2020).

The script performs the following steps:
1.  Downloads SOC data for three soil depths (0-5cm, 5-15cm, 15-30cm) directly at a 5-arcminute resolution.
2.  Calculates a weighted average for the 0-30cm depth.
3.  Projects the data to the correct CRS.
4.  Duplicates the single-year data into a 29-layer stack (1992-2020).
