#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse); library(yaml); library(fs)
  library(readr); library(dplyr); library(tibble)
  library(ggplot2); library(terra); library(sf)
  library(rnaturalearth); library(rnaturalearthdata)
})

opt_list <- list(
  optparse::make_option("--config", type="character",
                        default="SOM_analysis/config/figures_config.yaml")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = opt_list))
cfg <- yaml::read_yaml(opt$config)

resolve_path <- function(rel) file.path("SOM_analysis", rel)

cell_to_group_rds <- resolve_path(cfg$inputs$cell_to_group_rds)
spatial_ref_rds   <- resolve_path(cfg$inputs$spatial_ref_rds)
palette_csv       <- resolve_path(cfg$inputs$archetype_palette_csv)
out_dir           <- resolve_path(cfg$out_dir %||% "images/figures")
fs::dir_create(out_dir)

proj <- cfg$maps$projection %||% "+proj=robin +datum=WGS84"
dpi  <- cfg$maps$dpi %||% 450
size <- cfg$maps$size_in %||% c(10, 6)
do_smooth <- isTRUE(cfg$maps$smoothing)

period_filter <- cfg$maps$period
filter_to_one <- !is.null(period_filter) && nzchar(period_filter)

# Load data
df <- readr::read_rds(cell_to_group_rds)
spatial_ref <- readr::read_rds(spatial_ref_rds)
pal_df <- readr::read_csv(palette_csv, show_col_types = FALSE) %>%
  dplyr::transmute(archetypeID, group = as.integer(group), hex_color)

# Join coords + colors
df <- df %>%
  dplyr::left_join(pal_df, by = c("archetypeID", "group")) %>%
  dplyr::left_join(spatial_ref, by = "ID") %>%
  tidyr::drop_na(x, y, archetypeID, group, hex_color)

if (filter_to_one) {
  df <- df %>% dplyr::filter(.data$PERIOD == period_filter)
}

# Basemap
world <- rnaturalearth::ne_countries(scale = 50, returnclass = "sf") %>%
  dplyr::filter(iso_a3 != "ATA") %>%
  sf::st_transform(proj)

# Color map
full_color_match <- setNames(pal_df$hex_color, as.character(pal_df$archetypeID))

periods <- sort(unique(df$PERIOD))
for (pp in periods) {
  message("full map ", pp)
  df_pp <- df %>%
    dplyr::filter(.data$PERIOD == pp) %>%
    dplyr::select(x, y, archetypeID)

  rr <- terra::rast(dplyr::rename(df_pp, value = archetypeID), type = "xyz")
  terra::crs(rr) <- "EPSG:4326"

  if (isTRUE(do_smooth)) {
    rr_s <- terra::focal(rr, w = 3, fun = "modal", expand = FALSE, na.rm = TRUE)
    rr_s[is.na(rr)] <- NA
  } else rr_s <- rr

  rr_p <- terra::project(rr_s, proj, method = "near")

  df_plot <- as.data.frame(rr_p, xy = TRUE, na.rm = TRUE)
  names(df_plot)[3] <- "archetypeID"
  df_plot$archetypeID <- as.character(df_plot$archetypeID)

  p <- ggplot() +
    geom_raster(data = df_plot, aes(x = x, y = y, fill = archetypeID)) +
    geom_sf(data = world, fill = NA, color = "grey30", size = 0.2) +
    coord_sf(crs = proj, expand = FALSE) +
    scale_fill_manual(values = full_color_match, drop = FALSE) +
    theme_void() +
    theme(legend.position = "none", plot.margin = margin(0,0,0,0))

  outfile <- if (filter_to_one) {
    file.path(out_dir, sprintf("som2_groups_full_%s.png", gsub("[^0-9A-Za-z_-]", "", period_filter)))
  } else {
    file.path(out_dir, sprintf("som2_groups_full_%s.png", pp))
  }

  ggplot2::ggsave(filename = outfile, plot = p, width = size[1], height = size[2], dpi = dpi)
  if (filter_to_one) break
}
