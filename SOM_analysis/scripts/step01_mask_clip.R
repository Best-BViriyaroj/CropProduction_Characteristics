suppressPackageStartupMessages({ library(yaml); library(terra); library(fs); library(here) })
source(here::here("SOM_analysis/R/01_mask_clip.R"))

cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))
datasets  <- cfg$datasets
masked_dir <- here::here("SOM_analysis", cfg$output$masked_dir); dir_create(masked_dir)

BOKUmask <- rast(here::here("CropProductionPhysicalSOM", cfg$mask_path)) # robust if run from repo root
if (!file.exists(here::here(cfg$mask_path))) BOKUmask <- rast(here::here("SOM_analysis", cfg$mask_path))
clip_ext <- ext(cfg$clip_extent)

for (nm in names(datasets)) {
  infile  <- here::here("CropProductionPhysicalSOM", datasets[[nm]])
  if (!file.exists(infile)) infile <- here::here("SOM_analysis", datasets[[nm]])
  outfile <- here::here("SOM_analysis", masked_dir, paste0(nm, "_MASKED.tif"))
  cat("Masking:", nm, "\n")
  mask_one(infile, outfile, BOKUmask, clip_ext)
}