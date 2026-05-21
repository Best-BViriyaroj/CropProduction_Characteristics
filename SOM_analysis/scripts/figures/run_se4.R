#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse); library(yaml); library(fs)
})

# CLI
opt_list <- list(
  optparse::make_option("--config", type="character",
                        default="SOM_analysis/config/figures_config.yaml",
                        help="Path to figures config YAML"),
  optparse::make_option("--force", action="store_true", default=FALSE,
                        help="Force rebuild of groups/palette even if outputs exist")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = opt_list))

# Ensure packages are installed (minimal set used by called scripts)
ensure_packages <- function(pkgs) {
  to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
  if (length(to_install)) install.packages(to_install, repos = "https://cloud.r-project.org")
}
ensure_packages(c(
  "yaml","optparse","fs","readr","dplyr","tibble","cluster",
  "ggplot2","terra","sf","rnaturalearth","rnaturalearthdata"
))

cfg <- yaml::read_yaml(opt$config)
resolve_path <- function(rel) file.path("SOM_analysis", rel)

# Outputs that gate the grouping stage
archetype_to_group_rds <- resolve_path(cfg$inputs$archetype_to_group_rds)
cell_to_group_rds      <- resolve_path(cfg$inputs$cell_to_group_rds)
palette_csv            <- resolve_path(cfg$inputs$archetype_palette_csv)

need_groups <- opt$force ||
  !file.exists(archetype_to_group_rds) ||
  !file.exists(cell_to_group_rds) ||
  !file.exists(palette_csv)

if (need_groups) {
  message("Building k=7 grouping and palette...")
  system2("Rscript",
          c("SOM_analysis/scripts/figures/utils/export_groups_k7.R",
            "--config", opt$config),
          stdout = "", stderr = "")
} else {
  message("Grouping and palette already exist. Use --force to rebuild.")
}

# Generate full group maps
message("Rendering group maps...")
system2("Rscript",
        c("SOM_analysis/scripts/figures/02_group_map.R",
          "--config", opt$config),
        stdout = "", stderr = "")

# Generate dendrogram
message("Rendering dendrogram...")
system2("Rscript",
        c("SOM_analysis/scripts/figures/03_dendrogram.R",
          "--config", opt$config),
        stdout = "", stderr = "")

message("SE4 completed.")
