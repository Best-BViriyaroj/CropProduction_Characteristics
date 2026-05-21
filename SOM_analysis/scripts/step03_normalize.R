suppressPackageStartupMessages({ library(yaml); library(terra); library(fs); library(here) })
source(here::here("SOM_analysis/R/03_normalize.R"))

cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))
avg_dir  <- here::here("SOM_analysis", cfg$output$avg_dir)
norm_dir <- here::here("SOM_analysis", cfg$output$norm_dir); dir_create(norm_dir)

BOKUmask <- crop(rast(here::here("CropProductionPhysicalSOM", cfg$mask_path)), ext(cfg$clip_extent))
period_names <- vapply(cfg$periods, function(p) paste0(p[[1]], "-", p[[2]]), character(1))

avg_files <- dir_ls(avg_dir, regexp = "_1992-2020_4y\\.tif$")
for (f in avg_files) {
  normalize_one(
    file_path = f, norm_dir = norm_dir, BOKUmask = BOKUmask,
    clip_extent = ext(cfg$clip_extent), period_names = period_names,
    percentile_datasets = cfg$percentile_datasets
  )
}