# This file implements your "restructure stacks" and data frame exports.
# Paste your existing code, replacing base_new/input_dir/output_dir with cfg$output locations.

suppressPackageStartupMessages({ library(yaml); library(terra); library(readr); library(dplyr); library(fs); library(here) })
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

input_dir  <- here::here("SOM_analysis", cfg$output$cleaned_dir)
output_dir <- here::here("SOM_analysis", cfg$output$final_dir); dir_create(output_dir)

# Paste your "restructure stacks" code here. Ensure file discovery reads from input_dir and writes to output_dir.