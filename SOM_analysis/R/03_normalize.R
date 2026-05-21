suppressPackageStartupMessages({ library(terra) })

clean_name <- function(x) {
  x <- gsub("_1992-2020_4y\\.tif$", "", x)
  x <- gsub("\\.tif$", "", x)
  x
}

get_stats_all_layers <- function(r, do_pct = FALSE) {
  v <- values(r); v <- v[is.finite(v)]
  if (length(v) == 0) return(list(p2.5 = NA, p97.5 = NA, mean = NA, sd = NA))
  if (do_pct) {
    p2.5  <- as.numeric(quantile(v, 0.025, na.rm = TRUE))
    p97.5 <- as.numeric(quantile(v, 0.975, na.rm = TRUE))
    v <- v[v >= p2.5 & v <= p97.5]
  } else { p2.5 <- NA_real_; p97.5 <- NA_real_ }
  m <- mean(v); sdv <- sd(v); if (!is.finite(sdv) || sdv <= 0) sdv <- 1
  list(p2.5 = p2.5, p97.5 = p97.5, mean = m, sd = sdv)
}

normalize_one <- function(file_path, norm_dir, BOKUmask, clip_extent, period_names,
                          percentile_datasets = character()) {
  dataset_name <- clean_name(basename(file_path))
  r <- rast(file_path) |> crop(clip_extent)
  
  if (nlyr(r) == length(period_names)) {
    if (is.null(names(r)) || any(names(r) == "")) names(r) <- period_names
  }
  
  if (!compareGeom(r[[1]], BOKUmask, stopOnError = FALSE)) {
    mask2 <- resample(BOKUmask, r[[1]], method = "near")
  } else mask2 <- BOKUmask
  
  r <- mask(r, mask2)
  
  do_pct <- dataset_name %in% percentile_datasets
  stats  <- get_stats_all_layers(r, do_pct = do_pct)
  if (do_pct && is.finite(stats$p2.5) && is.finite(stats$p97.5)) {
    r <- clamp(r, lower = stats$p2.5, upper = stats$p97.5, values = TRUE)
  }
  
  r_norm <- (r - stats$mean) / stats$sd
  r_norm <- clamp(r_norm, lower = -2, upper = 2, values = TRUE)
  names(r_norm) <- period_names
  
  out_path <- file.path(norm_dir, paste0(dataset_name, "_norm.tif"))
  dir.create(dirname(out_path), recursive = TRUE, showWarnings = FALSE)
  writeRaster(r_norm, out_path, overwrite = TRUE,
              wopt = list(datatype = "FLT4S", gdal = c("COMPRESS=LZW","TILED=YES","BIGTIFF=IF_SAFER")))
  invisible(out_path)
}