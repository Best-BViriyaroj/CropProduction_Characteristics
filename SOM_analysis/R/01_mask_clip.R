suppressPackageStartupMessages({ library(terra); library(fs) })

ensure_year_names <- function(r, years) {
  want <- paste0("y", years)
  nm <- names(r)
  if (is.null(nm) || length(nm) != length(want) || !all(want %in% nm)) {
    names(r) <- want
  }
  r
}

mask_one <- function(infile, out_file, mask_r, clip_ext) {
  r <- rast(infile) |> crop(clip_ext)
  m <- crop(mask_r, clip_ext)
  if (!compareGeom(r[[1]], m, stopOnError = FALSE)) {
    m <- resample(m, r[[1]], method = "near")
  }
  r <- mask(r, m)
  dir_create(path_dir(out_file))
  writeRaster(r, out_file, overwrite = TRUE,
              wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=IF_SAFER")))
  invisible(out_file)
}