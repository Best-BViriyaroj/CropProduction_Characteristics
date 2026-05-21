suppressPackageStartupMessages({
  library(yaml); library(aweSOM); library(clusterSim); library(readr); library(tibble); library(dplyr)
  library(fs); library(here)
})
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

in_rds      <- here::here("SOM_analysis", cfg$output$final_dir, "full_data_combined_1992-2020_7periods.rds")
models_dir  <- here::here("SOM_analysis", cfg$output$models_dir)
metrics_dir <- here::here("SOM_analysis", cfg$output$metrics_dir, "som_performance_full")
dir_create(metrics_dir)

df <- readr::read_rds(in_rds)
X  <- as.matrix(df[, !(names(df) %in% c("ID","PERIOD")), drop = FALSE])

som_files <- dir_ls(models_dir, glob = sprintf("som_%dx%d_run*.rds", cfg$som$grid$xdim, cfg$som$grid$ydim))
if (length(som_files) == 0) stop("No SOM model files found in: ", models_dir)

all_metrics <- list()

for (f in som_files) {
  som <- readr::read_rds(f)
  sq  <- aweSOM::somQuality(som = som, traindat = X)
  db  <- clusterSim::index.DB(x = X, cl = som$unit.classif)
  
  m <- tibble(
    model_file = path_file(f),
    xdim = som$grid$xdim, ydim = som$grid$ydim, rlen = som$parameters$rlen,
    err_quant = as.numeric(sq$err.quant[1]),
    err_varratio = as.numeric(sq$err.varratio[1]),
    err_kaski = as.numeric(sq$err.kaski[1]),
    err_topo = as.numeric(sq$err.topo[1]),
    DB = as.numeric(db$DB[1])
  )
  out_rds <- file.path(metrics_dir, paste0(path_ext_remove(path_file(f)), "_metrics.rds"))
  readr::write_rds(m, out_rds)
  all_metrics[[length(all_metrics)+1]] <- m
  cat("metrics:", path_file(out_rds), "\n")
}

# Save combined metrics table
comb <- bind_rows(all_metrics) %>% arrange(DB, err_quant)
readr::write_rds(comb, file.path(metrics_dir, "som_full_metrics_combined.rds"))
readr::write_csv(comb, file.path(metrics_dir, "som_full_metrics_combined.csv"))