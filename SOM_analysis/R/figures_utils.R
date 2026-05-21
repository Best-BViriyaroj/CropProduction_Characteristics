suppressPackageStartupMessages({
  library(terra); library(sf); library(dplyr); library(readr); library(ggplot2); library(rnaturalearth)
})

load_or_make_palette <- function(palette_csv, archetype_ids) {
  if (!is.null(palette_csv) && palette_csv != "" && file.exists(palette_csv)) {
    pal <- readr::read_csv(palette_csv, show_col_types = FALSE)
    stopifnot(all(c("archetypeID","hex_color") %in% names(pal)))
    pal <- pal %>% filter(archetypeID %in% archetype_ids)
    setNames(pal$hex_color, pal$archetypeID)
  } else {
    hues <- scales::hue_pal()(length(archetype_ids))
    setNames(hues, archetype_ids)
  }
}

rasterize_and_project <- function(df_xy, value_col, proj_crs, smoothing = TRUE) {
  r <- terra::rast(df_xy %>% dplyr::select(x, y, value = dplyr::all_of(value_col)), type = "xyz")
  crs(r) <- "EPSG:4326"
  if (smoothing) {
    r_smooth <- terra::focal(r, w = 3, fun = "modal", expand = FALSE, na.rm = TRUE)
    r_smooth[is.na(r)] <- NA
  } else {
    r_smooth <- r
  }
  terra::project(r_smooth, proj_crs, method = "near")
}

world_basemap <- function(proj_crs) {
  rnaturalearth::ne_countries(scale = 50, returnclass = "sf") |>
    dplyr::filter(iso_a3 != "ATA") |>
    sf::st_transform(proj_crs)
}