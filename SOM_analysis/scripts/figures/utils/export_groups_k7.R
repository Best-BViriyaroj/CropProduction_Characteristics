#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library(optparse); library(yaml); library(fs)
  library(readr); library(dplyr); library(tibble); library(cluster)
  library(purrr)
})

# CLI
opt_list <- list(
  optparse::make_option("--config", type="character",
                        default="SOM_analysis/config/figures_config.yaml")
)
opt <- optparse::parse_args(optparse::OptionParser(option_list = opt_list))
cfg <- yaml::read_yaml(opt$config)

resolve_path <- function(rel) file.path("SOM_analysis", rel)

# Inputs from config
som2_path         <- resolve_path(cfg$inputs$som2_selection_rds)
cell_to_arch_path <- resolve_path(cfg$inputs$cell_to_archetype_rds)

# Outputs from config
archetype_to_group_rds <- resolve_path(cfg$inputs$archetype_to_group_rds)
cell_to_group_rds      <- resolve_path(cfg$inputs$cell_to_group_rds)
palette_csv            <- resolve_path(cfg$inputs$archetype_palette_csv)

fs::dir_create(fs::path_dir(archetype_to_group_rds))
fs::dir_create(fs::path_dir(cell_to_group_rds))
fs::dir_create(fs::path_dir(palette_csv))

# 1) Load SOM2 codebook
som2 <- readr::read_rds(som2_path)

archetypes <- som2$codes[[1]] %>%
  as.data.frame() %>%
  mutate(archetypeID = dplyr::row_number()) %>%
  tibble::as_tibble()

som_mat <- archetypes %>%
  dplyr::select(-archetypeID) %>%
  dplyr::mutate(dplyr::across(dplyr::everything(), as.numeric)) %>%
  as.matrix()

# 2) Complete-linkage, stand=TRUE, k=7
final_k <- 7
hc <- as.hclust(cluster::agnes(som_mat, diss = FALSE, stand = TRUE, method = "complete"))
group_assignments <- cutree(hc, k = final_k)

archetype_to_group_k7 <- tibble::tibble(
  archetypeID = archetypes$archetypeID,
  group       = as.integer(group_assignments)
) %>% dplyr::arrange(group, archetypeID)

readr::write_rds(archetype_to_group_k7, archetype_to_group_rds)

# 3) Build cell->group using existing cell->archetype map
cell_to_arch <- readr::read_rds(cell_to_arch_path)
stopifnot(all(c("ID","PERIOD","archetypeID") %in% names(cell_to_arch)))

cell_to_group_k7 <- cell_to_arch %>%
  dplyr::left_join(archetype_to_group_k7, by = "archetypeID") %>%
  dplyr::arrange(PERIOD, ID)

stopifnot(!any(is.na(cell_to_group_k7$group)))
readr::write_rds(cell_to_group_k7, cell_to_group_rds)

# 4) Export palette using your best_palette (exactly as you provided)
best_palette <- list(
  c("#4AECE8"),
  c("#1E40AF", "#457ED9", "#88ADD7"),
  c("#7A003C", "#B02C51"),
  c("#E76F51", "#F4A261", "#D97706"),
  c("#6A4C93", "#8E7DBE"),
  c("#FFC300", "#E9C46A"),
  c("#2D6A4F", "#52B788", "#84CC16")
)

# Sanity: palette long enough for each group
counts_by_group <- archetype_to_group_k7 %>% dplyr::count(group, name = "n_archetypes")
pal_lengths <- tibble::tibble(group = seq_along(best_palette),
                              pal_n = purrr::map_int(best_palette, length))
check_df <- dplyr::left_join(counts_by_group, pal_lengths, by = "group")
if (any(check_df$n_archetypes > check_df$pal_n)) {
  print(check_df)
  stop("best_palette is too short for at least one group. Add colors.")
}

palette_df <- archetype_to_group_k7 %>%
  dplyr::group_by(group) %>%
  dplyr::arrange(archetypeID, .by_group = TRUE) %>%
  dplyr::mutate(hex_color = best_palette[[unique(group)]][dplyr::row_number()]) %>%
  dplyr::ungroup()

readr::write_csv(palette_df, palette_csv)

message("Saved:",
        "\n  ", archetype_to_group_rds,
        "\n  ", cell_to_group_rds,
        "\n  ", palette_csv)
