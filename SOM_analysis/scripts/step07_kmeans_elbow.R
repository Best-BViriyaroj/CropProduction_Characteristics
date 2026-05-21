suppressPackageStartupMessages({ library(yaml); library(readr); library(dplyr); library(ggplot2); library(fs); library(here) })
cfg <- yaml::read_yaml(here::here("SOM_analysis/config/som_config.yaml"))

final_dir <- here::here("SOM_analysis", cfg$output$final_dir)
out_dir   <- here::here("SOM_analysis", "data/metrics/kmeans"); dir_create(out_dir)

in_file <- file.path(final_dir, "full_data_combined_1992-2020_7periods.rds")
df_all  <- readr::read_rds(in_file)
X       <- as.matrix(df_all[, !(names(df_all) %in% c("ID","PERIOD")), drop = FALSE])

set.seed(cfg$kmeans$seed)
k_values <- cfg$kmeans$k_values

elbow_local <- lapply(k_values, function(k) {
  message("kmeans local: k=", k)
  km <- kmeans(X, centers = k, iter.max = 100)
  tibble::tibble(k = k, var_expl = km$betweenss / km$totss)
}) |> bind_rows()

readr::write_rds(elbow_local, file.path(out_dir, "elbow_results_local.rds"))
readr::write_csv(elbow_local, file.path(out_dir, "elbow_results_local.csv"))

hpc_dir <- here::here("SOM_analysis", cfg$kmeans$hpc_dir)
pattern <- cfg$kmeans$hpc_pattern
elbow_all <- elbow_local

if (dir_exists(hpc_dir)) {
  files <- dir_ls(hpc_dir, regexp = pattern, fail = FALSE)
  if (length(files) > 0) {
    hpc <- bind_rows(lapply(files, readRDS))
    elbow_all <- bind_rows(elbow_local, hpc) |>
      arrange(k) |>
      distinct(k, .keep_all = TRUE)
  }
}

readr::write_rds(elbow_all, file.path(out_dir, "elbow_results_all.rds"))
readr::write_csv(elbow_all, file.path(out_dir, "elbow_results_all.csv"))

label_k <- cfg$elbow$label_k
label_points <- elbow_all |> filter(k %in% label_k) |> mutate(label = paste0(round(var_expl*100,2), "%"))
p <- ggplot(elbow_all, aes(k, var_expl)) +
  geom_line() + geom_point(size=1.6) +
  geom_text(data=label_points, aes(label=label), vjust=2.2, size=3) +
  theme_minimal(base_size=13) + labs(x="k", y="Explained variance (betweenSS / totalSS)")
ggsave(file.path(out_dir, "elbowcurve_all_linearx.png"), p, width = 10, height = 6, dpi = 450, bg = "white")