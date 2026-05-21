#Create all required directories

dirs <- c(
  "data_input/LUIcube_HANPPharv",
  "data_input/mask",
  "data_input/stack_dataset",
  "SOM_analysis/config",
  "SOM_analysis/R",
  "SOM_analysis/scripts/figures",
  "SOM_analysis/data/interim/avg_4y_normalized/cleaned",
  "SOM_analysis/data/interim/masked",
  "SOM_analysis/data/interim/avg_4y",
  "SOM_analysis/data/interim/final",
  "SOM_analysis/data/models/exports",
  "SOM_analysis/data/models/som_files_full",
  "SOM_analysis/data/models/som2_selections",
  "SOM_analysis/data/models/som2_files",
  "SOM_analysis/data/metrics/kmeans/puhti_results",
  "SOM_analysis/data/metrics/som_performance_full",
  "SOM_analysis/images/qa",
  "SOM_analysis/images/figures/meta"
)
invisible(lapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE))