# This file implements your "master mask" cleanup step.
# Paste your existing "final cleanup: master mask" code here,
# then adjust base_new/norm_dir/clean_dir/plot_dir to read from cfg$output paths.

suppressPackageStartupMessages({ library(yaml); library(terra); library(data.table); library(fs); library(ggplot2); library(rnaturalearth); library(sf); library(here); library(tidyterra) })
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

base_new <- here::here("SOM_analysis")
norm_dir  <- here::here("SOM_analysis", cfg$output$norm_dir)
clean_dir <- here::here("SOM_analysis", cfg$output$cleaned_dir); dir_create(clean_dir)
plot_dir  <- here::here("SOM_analysis", "images/qa"); dir_create(plot_dir)

# Paste your master mask building loop here, replacing hard-coded paths with norm_dir/clean_dir/plot_dir.
# Save master mask into file.path(base_new, "data/interim/master_mask_7periods_norm.tif")
# Note: keep geometry consistent with normalized stacks.