suppressPackageStartupMessages({ library(yaml); library(readr); library(dplyr); library(corrplot); library(fs); library(here) })
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

final_dir <- here::here("SOM_analysis", cfg$output$final_dir)
out_dir   <- file.path(final_dir, "correlations"); dir_create(out_dir)

period_names <- vapply(cfg$periods, function(p) paste0(p[[1]], "-", p[[2]]), character(1))
pretty_names <- c(SOC="SOC", Phosphorus="Phosphorus", SoilMoisture="Soil Moisture", Nitrogen="Nitrogen",
                  AridityIndex="Aridity Index", Precipitation="Precipitation", GDD="Growing Degree Days", Evaporation="Evaporation")

plot_corr <- function(df, file_png, title_txt, pretty_map = NULL) {
  cols <- setdiff(names(df), c("ID", "PERIOD"))
  df2 <- df[, cols, drop = FALSE]
  cor_mat <- round(cor(df2, use = "complete.obs", method = "pearson"), 2)
  if (!is.null(pretty_map)) {
    nm <- colnames(cor_mat); lab <- ifelse(nm %in% names(pretty_map), pretty_map[nm], nm)
    rownames(cor_mat) <- lab; colnames(cor_mat) <- lab
  }
  png(file_png, width = 1200, height = 1050, res = 140)
  corrplot::corrplot(cor_mat, method="shade", type="upper", tl.cex=0.9, number.cex=0.7,
                     addCoef.col="black", tl.col="black", tl.srt=45, mar=c(0,0,2,0), title=title_txt)
  dev.off()
}

for (per in period_names) {
  f <- file.path(final_dir, paste0("full_data_", per, ".rds"))
  stopifnot(file.exists(f))
  df <- readr::read_rds(f)
  png_out <- file.path(out_dir, paste0("correlation_matrix_", per, ".png"))
  plot_corr(df, png_out, paste0("correlations (normalized) • ", per), pretty_map = pretty_names)
}

f_all <- file.path(final_dir, "full_data_combined_1992-2020_7periods.rds")
if (file.exists(f_all)) {
  df_all <- readr::read_rds(f_all)
  png_out <- file.path(out_dir, "correlation_matrix_combined_1992-2020_7periods.png")
  plot_corr(df_all, png_out, "correlations (normalized) • combined 1992–2020 (7 periods)", pretty_map = pretty_names)
}