suppressPackageStartupMessages({ library(yaml); library(kohonen); library(readr); library(fs); library(here) })
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

in_rds     <- here::here("SOM_analysis", cfg$output$final_dir, "full_data_combined_1992-2020_7periods.rds")
models_dir <- here::here("SOM_analysis", cfg$output$models_dir); dir_create(models_dir)

df <- readr::read_rds(in_rds)
X  <- as.matrix(df[, !(names(df) %in% c("ID","PERIOD")), drop = FALSE])

for (i in seq_len(cfg$som$runs)) {
  out_rds <- file.path(models_dir, sprintf("som_%dx%d_run%02d.rds", cfg$som$grid$xdim, cfg$som$grid$ydim, i))
  if (!file.exists(out_rds)) {
    set.seed(cfg$som$seed_base + i)
    som_obj <- kohonen::supersom(
      data = X,
      grid = kohonen::somgrid(xdim = cfg$som$grid$xdim, ydim = cfg$som$grid$ydim, topo = cfg$som$grid$topo),
      rlen = cfg$som$rlen,
      alpha = unlist(cfg$som$alpha),
      keep.data = TRUE
    )
    readr::write_rds(som_obj, out_rds)
    cat("trained:", basename(out_rds), "\n")
  }
}