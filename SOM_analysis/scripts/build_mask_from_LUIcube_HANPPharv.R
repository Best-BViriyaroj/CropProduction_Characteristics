#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(terra); library(fs); library(dplyr); library(rnaturalearth); library(sf); library(here)
})

root_code   <- here::here("SOM_analysis")
root_input  <- here::here("../data_input")

luicube_dir      <- file.path(root_input, "LUIcube_HANPPharv")
interim_dir       <- file.path(root_code, "data/interim/mask")
yearly_totals_dir <- file.path(interim_dir, "luicube_CL_yearly_total")
binary_dir        <- file.path(interim_dir, "binary_masks_30s")
final_mask_dir    <- file.path(root_input, "mask")

dir_create(yearly_totals_dir); dir_create(binary_dir); dir_create(final_mask_dir)

all_files <- dir_ls(luicube_dir, glob = "*.tif")
if (length(all_files) == 0) stop("No .tif files found in: ", luicube_dir)
all_files <- all_files[grepl("CL", basename(all_files))]
if (length(all_files) == 0) stop("No crop-layer .tif files (matching 'CL') found in: ", luicube_dir)

years <- as.integer(sub(".*(\\d{4}).*", "\\1", basename(all_files)))
uniq_years <- sort(unique(years))
message("Building yearly totals from ", length(all_files), " crop layers across ", length(uniq_years), " years")

yearly_total_paths <- lapply(uniq_years, function(yr) {
  files_for_year <- all_files[years == yr]
  r_stack <- rast(files_for_year)
  r_total <- app(r_stack, "sum", na.rm = TRUE)
  out_path <- file.path(yearly_totals_dir, paste0("LUIcube_HANPPharv_total_", yr, ".tif"))
  writeRaster(r_total, out_path, overwrite = TRUE,
              wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=IF_SAFER")))
  out_path
}) |> unlist()

message("Computing 5% quantile per year and taking the minimum...")
yearly_thresholds <- sapply(yearly_total_paths, function(f) {
  r <- rast(f); vals <- values(r, na.rm = TRUE); nz <- vals[vals > 0]
  if (length(nz) == 0) return(NA_real_)
  as.numeric(quantile(nz, probs = 0.05, na.rm = TRUE))
})
final_threshold <- min(yearly_thresholds, na.rm = TRUE)
message("Final threshold (min 5% quantile): ", signif(final_threshold, 6))

binary_mask_paths <- lapply(yearly_total_paths, function(f) {
  r <- rast(f); r_bin <- r
  r_bin[r_bin <  final_threshold] <- NA
  r_bin[r_bin >= final_threshold] <- 1
  out_path <- file.path(binary_dir, paste0("binary_", basename(f)))
  writeRaster(r_bin, out_path, overwrite = TRUE,
              wopt = list(datatype = "INT1U", gdal = c("COMPRESS=LZW","TILED=YES")))
  out_path
}) |> unlist()

land_30s <- rast(yearly_total_paths[1]); land_30s[!is.na(land_30s)] <- 1
land_5min <- aggregate(land_30s, fact = 10, fun = "max", na.rm = TRUE)
total_area_5min <- cellSize(land_5min, unit = "ha")

min_fraction_5min <- NULL
for (f in binary_mask_paths) {
  yr <- sub(".*_(\\d{4})\\.tif$", "\\1", basename(f))
  message("Aggregating yearly binary to 5': ", yr)
  yearly_bin_30s <- rast(f)
  prep <- yearly_bin_30s; prep[is.na(prep) & !is.na(land_30s)] <- 0
  area_30s <- cellSize(prep, unit = "ha")
  crop_area <- prep * area_30s
  crop_5min <- aggregate(crop_area, fact = 10, fun = "sum", na.rm = TRUE)
  frac_5min <- crop_5min / total_area_5min
  min_fraction_5min <- if (is.null(min_fraction_5min)) frac_5min else app(c(min_fraction_5min, frac_5min), "min", na.rm = TRUE)
}
names(min_fraction_5min) <- "min_yearly_fraction"
min_fraction_5min <- mask(min_fraction_5min, land_5min)

mask_10pct <- min_fraction_5min
mask_10pct[mask_10pct <  0.10] <- NA
mask_10pct[mask_10pct >= 0.10] <- 1
names(mask_10pct) <- "mask_10pct"

out_min_frac <- file.path(final_mask_dir, "min_yearly_fraction_5min.tif")
out_mask10   <- file.path(final_mask_dir, "mask_10pct.tif")
writeRaster(min_fraction_5min, out_min_frac, overwrite = TRUE,
            wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=IF_SAFER")))
writeRaster(mask_10pct, out_mask10, overwrite = TRUE,
            wopt = list(datatype = "INT1U",  gdal = c("COMPRESS=LZW","TILED=YES")))
cat("Saved:\n  ", out_min_frac, "\n  ", out_mask10, "\n", sep = "")

try({
  world <- rnaturalearth::ne_countries(scale = 50, returnclass = "sf")
  png(file.path(final_mask_dir, "mask_10pct_sanity.png"), width = 2000, height = 1000, res = 200)
  plot(mask_10pct, main = "Cropland mask (>= 10% min yearly fraction, 5 arc-min)", col = "darkgreen", legend = FALSE)
  plot(sf::st_geometry(world), add = TRUE, border = "grey40", lwd = 0.3)
  dev.off()
})