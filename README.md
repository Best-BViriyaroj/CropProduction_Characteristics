## Global Crop Production Physical System

**Author:** {{ "Best"" Bhattarabhop Viriyaroj }}  
**Contact:** {{ bhattarabhop.viriyaroj@aalto.fi }}
**Organization:** {{ Aalto University }}

## How to navigate the repository
* Below this section is the general details of the research
* Standard Element 1 (SE1) or data acquisition and Standard Element 2 (SE2) or data process can be found in the 'data_input' directory
* Standard Element 3 (SE3) or data analysis and Standard Element 4 (SE4) or data visualisation can be found in the 'SOM_analysis' directory
* There are readme files in those folders. Please read them before using the script
* Please run the functions.Rmd before running the scripts
* You can look at the results from the 'final_figures' directory

## Abstract
Crops play a crucial role in sustaining global food security, yet they also contribute to significant environmental degradation. Despite their significance, global studies often fail to account for the diverse variables impacting crop production within human and natural systems. In this study, we utilise a novel method—Two-Stage Self-Organising Maps—to systematically analyse key global datasets on crop production inputs provided by experts. Our analysis incorporates interdisciplinary datasets covering diverse sub-systems, including soil indicators, water-related metrics, and socio-economic variables. This approach will enable us to develop the first comprehensive global mapping of crop production system typologies at 5 arcminute resolutions for the period 1993 to 2020. The resulting typologies will be categorised into major groupings, highlighting the similarities and differences in crop production systems worldwide. We will further visualise the evolution of these characteristics and groupings across multiple timesteps, capturing the dynamic progression of global crop production systems. By establishing these typologies, we are aiming to facilitate communication pathways among experts to share best practices internationally, while also providing foundational insights for advancing research in crop and food systems analysis.

## Project Overview
{{ Description }}

* problem statement: Understanding the system is important to make it more sustainable, especially for a complex system such as crops
* Keywords: System Thinking, Sustainability Intensification, Multidisciplinary
* challenge statement: No research has tried to create global characteristics using global dataset through machine learning before, mainly because of the availability of the datasets and the computation power.
* solution statement: The characteristic of the biophysical system of the crop production will be mapped
* objective: Using Two-stage self-organising map with the multiple global datasets I will create the characteristics
* literature review: Huggins et al. 2025, Jung et al. 2024
* research questions: What are the characteristics of the crop production across the world?


## Method Summary
* Expert's Eliciation
* Two-stage Self-Organising Maps
* Correlation analysis
* Hierarchichal Analysis

## Input datasets

| Dataset               | Spatial Resolution | Temporal Resolution | Source                                                  |
| :-------------------- | :----------------- | :------------------ | :------------------------------------------------------ |
| Aridity Index         | 0.1°               | Monthly             | Calculated from MSWEP (Wang et al. 2025) and GLEAMv4 (Miralles et al. 2025)|
| Evaporation           | 0.1°               | Monthly             | GLEAMv4 (Miralles et al. 2025)                          |
| Growing Degree Days   | 0.1°               | Daily               | Calculated from MSWX, Paredes et al. 2025, and Matej et al. 2025 |
| Nitrogen              | 5 arc-minutes      | Static              | SoilGrids (Poggio et al. 2021)                          |
| Phosphorus            | 5 arc-minutes      | Static              | Mcdowell et al. 2023                                    |
| Precipitation         | 0.1°               | Monthly             | MSWEP V3 (Wang et al. 2025)                             |
| Soil Moisture         | 0.1°               | Monthly             | GLEAMv4 (Miralles et al. 2025)                          |
| Soil Organic Carbon   | 5 arc-minutes      | Static              | SoilGrids (Poggio et al. 2021)                          |
