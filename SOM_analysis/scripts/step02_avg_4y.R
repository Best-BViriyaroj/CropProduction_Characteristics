suppressPackageStartupMessages({ library(yaml); library(terra); library(fs); library(here) })
source(here::here("SOM_analysis/R/01_mask_clip.R"))
source(here::here("SOM_analysis/R/02_avg_4y.R"))

cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))
masked_dir <- here::here("SOM_analysis", cfg$output$masked_dir)
avg_dir    <- here::here("SOM_analysis", cfg$output$avg_dir); dir_create(avg_dir)

years <- seq(cfg$years[[1]], cfg$years[[2]])
periods_list <- lapply(cfg$periods, function(p) seq(p[[1]], p[[2]]))
names(periods_list) <- vapply(cfg$periods, function(p) paste0(p[[1]], "-", p[[2]]), character(1))

mask_r <- crop(rast(here::here("CropProductionPhysicalSOM", cfg$mask_path)), ext(cfg$clip_extent))

files <- dir_ls(masked_dir, regexp = "_MASKED\\.tif$")
names(files) <- gsub("_MASKED\\.tif$", "", path_file(files))

for (nm in names(files)) {
  calculate_4year_averages(
    input_path = files[[nm]], dataset_name = nm, output_dir = avg_dir,
    years = years, periods_list = periods_list, mask_r = mask_r, clip_ext = ext(cfg$clip_extent)
  )
}