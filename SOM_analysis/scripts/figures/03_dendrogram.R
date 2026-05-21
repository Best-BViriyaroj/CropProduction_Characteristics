#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse); library(yaml); library(fs)
  library(readr); library(dplyr); library(tibble)
  library(cluster)
})

opt_list <- list(
  optparse::make_option("--config", type="character",
                        default="SOM_analysis/config/figures_config.yaml")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = opt_list))
cfg <- yaml::read_yaml(opt$config)

resolve_path <- function(rel) file.path("SOM_analysis", rel)

som2_rds    <- resolve_path(cfg$inputs$som2_selection_rds)
palette_csv <- resolve_path(cfg$inputs$archetype_palette_csv)
out_dir     <- resolve_path(cfg$out_dir %||% "images/figures")
fs::dir_create(out_dir)

linkage <- (cfg$dendrogram$linkage %||% "complete")
stand_features <- isTRUE(cfg$dendrogram$stand_features)
k <- as.integer(cfg$dendrogram$k %||% 7)
dpi  <- cfg$dendrogram$dpi %||% 300
size <- cfg$dendrogram$size_in %||% c(8, 6)

# Load SOM2 codebook
som2 <- readr::read_rds(som2_rds)

archetypes <- som2$codes[[1]] %>%
  as.data.frame() %>%
  mutate(archetypeID = dplyr::row_number()) %>%
  tibble::as_tibble()

som_mat <- archetypes %>%
  dplyr::select(-archetypeID) %>%
  dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
  as.matrix()

# Fit hierarchical clustering
agn <- cluster::agnes(som_mat, diss = FALSE, stand = stand_features, method = linkage)
hc <- as.hclust(agn)

# Cut at k
group_assignments <- stats::cutree(hc, k = k)

# Read palette CSV
pal_df <- readr::read_csv(palette_csv, show_col_types = FALSE) %>%
  dplyr::transmute(archetypeID, group = as.integer(group), hex_color)

# One color per group (first archetype’s color)
rect_cols_by_group <- pal_df %>%
  dplyr::group_by(group) %>%
  dplyr::arrange(archetypeID, .by_group = TRUE) %>%
  dplyr::summarise(rect_col = dplyr::first(hex_color), .groups = "drop") %>%
  dplyr::arrange(group) %>%
  dplyr::pull(rect_col)

# Reorder to match left->right cluster traversal
ord <- hc$order
cl_ord <- group_assignments[ord]
cluster_lr <- unique(cl_ord)
rect_cols_lr <- rect_cols_by_group[cluster_lr]

# Save PNG
outfile_png <- file.path(out_dir, sprintf("som2_dendrogram_%s_k%d.png", linkage, k))
png(outfile_png, width = size[1]*dpi, height = size[2]*dpi, res = dpi, bg = "white")
hmax <- max(hc$height)
plot(stats::as.dendrogram(hc),
     main = sprintf("Hierarchical clustering (method=%s, stand=%s), k=%d", linkage, stand_features, k),
     ylab = "Height",
     xlab = "SOM2 archetypes",
     cex.lab = 1.1,
     cex.axis = 0.9,
     ylim = c(-0.5, hmax * 1.20))
oldpar <- par(no.readonly = TRUE)
par(lwd = 4)
rect.hclust(hc, k = k, border = rect_cols_lr)
par(oldpar)
dev.off()

message("Saved: ", outfile_png)
