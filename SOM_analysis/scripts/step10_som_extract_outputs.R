suppressPackageStartupMessages({
  library(yaml); library(readr); library(tibble); library(dplyr); library(fs); library(here)
})
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

# Inputs
final_df_rds <- here::here("SOM_analysis", cfg$output$final_dir, "full_data_combined_1992-2020_7periods.rds")
models_dir   <- here::here("SOM_analysis", cfg$output$models_dir)
metrics_dir  <- here::here("SOM_analysis", cfg$output$metrics_dir, "som_performance_full")

# Output export folder
out_dir <- here::here("SOM_analysis", "data/models/exports")
dir_create(out_dir)

# Choose a model to export:
# Option A: pick the best by DB (lowest) from combined metrics
comb_metrics <- file.path(metrics_dir, "som_full_metrics_combined.rds")
if (!file.exists(comb_metrics)) stop("Run step09_som_evaluate.R first (missing combined metrics).")
mtx <- readr::read_rds(comb_metrics)
best_file <- mtx %>% arrange(DB, err_quant) %>% slice(1) %>% pull(model_file)
som_path  <- file.path(models_dir, best_file)

cat("Exporting outputs for best model:", best_file, "\n")

# Load model and data
som <- readr::read_rds(som_path)
df  <- readr::read_rds(final_df_rds)

# BMU assignments
bmu <- tibble(
  row_id = seq_len(nrow(df)),
  ID = df$ID,
  PERIOD = df$PERIOD,
  BMU = som$unit.classif
)
readr::write_rds(bmu, file.path(out_dir, "bmu_assignments.rds"))
readr::write_csv(bmu, file.path(out_dir, "bmu_assignments.csv"))

# Codebooks (fit coefficients)
codes <- som$codes[[1]]
codes_df <- as_tibble(codes) %>% mutate(node_id = dplyr::row_number(), .before = 1)
readr::write_rds(codes_df, file.path(out_dir, "som_codebooks.rds"))
readr::write_csv(codes_df, file.path(out_dir, "som_codebooks.csv"))

# Session info snapshot for provenance
capture.output(sessionInfo(), file = here::here("SOM_analysis", "sessionInfo_SE3.txt"))

cat("Exports written to:", out_dir, "\n")