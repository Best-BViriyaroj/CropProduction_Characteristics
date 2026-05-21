suppressPackageStartupMessages({ library(terra) })
# ensure_year_names comes from 01_mask_clip.R

calculate_4year_averages <- function(input_path, dataset_name, output_dir,
                                     years, periods_list, mask_r, clip_ext = NULL) {
  r_all <- rast(input_path)
  if (!is.null(clip_ext)) r_all <- crop(r_all, clip_ext)
  r_all <- ensure_year_names(r_all, years)
  
  if (!compareGeom(r_all[[1]], mask_r, stopOnError = FALSE)) {
    mask2 <- resample(mask_r, r_all[[1]], method = "near")
  } else mask2 <- mask_r
  
  out_layers <- list()
  for (per in periods_list) {
    lbl <- paste0(per[1], "-", per[length(per)])
    sel_names <- paste0("y", per)
    r_sel <- r_all[[sel_names]]
    m <- mean(r_sel, na.rm = TRUE); names(m) <- lbl
    out_layers[[lbl]] <- m
  }
  
  final_stack <- rast(out_layers)
  out_file <- file.path(output_dir, paste0(dataset_name, "_1992-2020_4y.tif"))
  dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
  writeRaster(final_stack, out_file, overwrite = TRUE,
              wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=IF_SAFER")))
  invisible(out_file)
}