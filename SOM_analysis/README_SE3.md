SE3: Model Train, Validate, and Interpret

Overview
This repository implements a FAIR, reproducible pipeline to:
- Build a global cropland mask from LUIcube_HANPPharv (minimum-yearly-coverage method)
- Mask/clip environmental stacks, aggregate into 7 four-year periods (1992–2020)
- Normalize and master-mask the data
- Restructure to period-wise variable stacks and final data tables
- Run k-means elbow (local + auto-merge HPC results)
- Train Self-Organizing Maps (SOM) and evaluate metrics
- Export interpretable outputs (BMUs, codebooks)

Project layout
- data_input/
  - LUIcube_HANPPharv/            per-crop, per-year 30" GeoTIFFs
  - mask/                          final mask outputs (mask_10pct.tif)
  - stack_dataset/                 environmental stacks
- SOM_analysis/
  - config/                        som_config.yaml (pipeline), figures_config.yaml (SE4)
  - R/                             reusable functions (no hard-coded paths)
  - scripts/                       entry-point scripts (read YAML and run steps)
  - data/                          interim, models, metrics (created by scripts)
  - images/                        QA and figures
  - README_SE3.md                  this file

R vs scripts
- R/: Reusable, modular functions and helpers. No hard-coded paths; functions take arguments and return values.
- scripts/: Executable entry points that read config/som_config.yaml, construct paths, call functions, and write outputs.

Mask derivation (LUIcube_HANPPharv → mask_10pct.tif)
Inputs: ../data_input/LUIcube_HANPPharv (CL per-crop, per-year 30" GeoTIFFs)

Method (minimum-yearly-coverage):
1) Yearly totals: For each year, sum all crop layers → LUIcube_HANPPharv_total_y.tif (30").
2) Stable threshold: For each year, compute the 5th percentile of non-zero values; choose T = min of yearly 5% quantiles.
3) Binary masks (30"): For each year, classify per cell: 1 if total ≥ T; NA otherwise.
4) Aggregate to 5': Area-weight each yearly 30" binary into a 5' fractional cropland coverage.
5) Minimum yearly fraction: Take per-cell min across years.
6) Final mask (5'): mask_10pct = 1 where min_yearly_fraction ≥ 0.10; NA elsewhere.

Reproduce:
- Rscript SOM_analysis/scripts/build_mask_from_LUIcube_HANPPharv.R
- Outputs:
  - ../data_input/mask/min_yearly_fraction_5min.tif
  - ../data_input/mask/mask_10pct.tif
  - ../data_input/mask/mask_10pct_sanity.png (optional)

Configuration (edit SOM_analysis/config/som_config.yaml)
- datasets: paths to environmental stacks (relative to repo root or absolute)
- mask_path: "../data_input/mask/mask_10pct.tif"
- clip_extent: [-180, 180, -60, 90]
- periods: seven 4-year periods covering 1992–2020
- percentile_datasets: clamp all except AridityIndex
- kmeans: K up to 100000; auto-merge HPC results from data/metrics/kmeans/puhti_results
- som: grid 18×18; rlen 300; alpha [0.05, 0.01]; runs=60; no extra scaling

Run order
1) Build mask (run once)
- Rscript SOM_analysis/scripts/build_mask_from_LUIcube_HANPPharv.R

2) Preprocess to final data
- Rscript SOM_analysis/scripts/step01_mask_clip.R
- Rscript SOM_analysis/scripts/step02_avg_4y.R
- Rscript SOM_analysis/scripts/step03_normalize.R
- Rscript SOM_analysis/scripts/step04_master_mask_clean.R
- Rscript SOM_analysis/scripts/step05_restructure_export.R
- Rscript SOM_analysis/scripts/step06_correlations.R

3) K-means elbow + auto-merge HPC
- Rscript SOM_analysis/scripts/step07_kmeans_elbow.R
- Optional: place .rds files (columns k,var_expl) into SOM_analysis/data/metrics/kmeans/puhti_results and re-run to merge

4) Train + evaluate SOM
- Rscript SOM_analysis/scripts/step08_som_train_full.R
- Rscript SOM_analysis/scripts/step09_som_evaluate.R
- Rscript SOM_analysis/scripts/step10_som_extract_outputs.R

5) Capture session info
- In R: capture.output(sessionInfo(), file = "SOM_analysis/sessionInfo_SE3.txt")

Model outputs and “fit coefficients”
- Codebooks (fit coefficients): SOM_analysis/data/models/exports/som_codebooks.csv|rds
- BMU assignments: SOM_analysis/data/models/exports/bmu_assignments.csv|rds
- SOM metrics: SOM_analysis/data/metrics/som_performance_full/ (per model) and combined CSV/RDS

Provenance
- All steps and parameters are recorded in YAML and scripts
- Session info saved to SOM_analysis/sessionInfo_SE3.txt
