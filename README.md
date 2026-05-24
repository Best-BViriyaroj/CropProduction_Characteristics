# Global Crop Production Biophysical System

**Author:** Bhattarabhop "Best" Viriyaroj  
**Contact:** bhattarabhop.viriyaroj@aalto.fi  
**Organization:** Aalto University

## Table of Contents
- [How to navigate the repository](#how-to-navigate-the-repository)
- [Abstract](#abstract)
- [Project Overview](#project-overview)
- [Getting Started](#getting-started)
- [Method Summary](#method-summary)
- [Input datasets](#input-datasets)
- [References](#references)

## How to navigate the repository
- General research details are provided below.
- `data_input`: SE1 (Standard Element 1 - data acquisition); SE2 (Standard Element 2 - data processing)
- `SOM_analysis`: SE3 (data analysis); SE4 (data visualisation)
- Please read the README files in those folders for further instructions.
- Run `functions.Rmd` before any other scripts.
- You can view results in the `final_figures` directory.

## Abstract
Crops play a crucial role in sustaining global food security, yet they also contribute to significant environmental degradation. Despite their significance, global studies often fail to account for the complex biophysical characteristics of crop systems at fine spatial and temporal scales. This project aims to bridge that gap by leveraging cutting-edge machine learning and multidisciplinary approaches.

## Project Overview
This project aims to map the biophysical characteristics of global crop production systems using a diverse set of global datasets and advanced analytical techniques.

- **Problem statement:** Understanding the crop production system is important for making it more sustainable, especially given its complexity.
- **Keywords:** System Thinking, Sustainability Intensification, Multidisciplinary
- **Challenge statement:** No research has previously attempted to create global crop system characteristics using global datasets and machine learning, primarily due to limitations in data availability and computational resources.
- **Solution statement:** The characteristics of crop production biophysical systems will be mapped globally.
- **Objective:** Utilize a two-stage self-organising map with multiple global datasets to characterize global crop production systems.
- **Literature review:** Huggins et al. 2025, Jung et al. 2024
- **Research questions:** What are the biophysical characteristics of crop production across the world?

## Getting Started

1. Clone this repository.
2. Install the required R packages as specified in each script or README file.
3. Read the README files in `data_input` and `SOM_analysis`.
4. Run `functions.Rmd` before running any analysis scripts.

## Method Summary
- Expert Elicitation
- Two-stage Self-Organising Maps
- Correlation Analysis
- Hierarchical Analysis

## Input datasets

| Dataset               | Spatial Resolution | Temporal Resolution | Source                                                  |
| :-------------------- | :----------------- | :------------------ | :------------------------------------------------------ |
| Aridity Index         | 0.1°               | Monthly             | Calculated from MSWEP (Wang et al. 2025) and GLEAMv4 (Miralles et al. 2025)|
| Evaporation           | 0.1°               | Monthly             | GLEAMv4 (Miralles et al. 2025)                          |
| Growing Degree Days   | 0.1°               | Daily               | Calculated from MSWX, Paredes et al. 2025, and Matej et al. 2025 |
| Nitrogen              | 5 arc-minutes      | Static              | SoilGrids (Poggio et al. 2021)                          |
| Phosphorus            | 5 arc-minutes      | Static              | McDowell et al. 2023                                    |
| Precipitation         | 0.1°               | Monthly             | MSWEP V3 (Wang et al. 2025)                             |
| Soil Moisture         | 0.1°               | Monthly             | GLEAMv4 (Miralles et al. 2025)                          |
| Soil Organic Carbon   | 5 arc-minutes      | Static              | SoilGrids (Poggio et al. 2021)                          |

## References

- Huggins et al. (2025)
- Jung et al. (2024)
- Miralles et al. (2025)
- Poggio et al. (2021)
- McDowell et al. (2023)
- Wang et al. (2025)
- Paredes et al. (2025)
- Matej et al. (2025)

---

For citation and licensing, please contact the author for details.
