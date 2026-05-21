# SE4: Figures (CropProductionPhysicalSOM)

This stage renders:
- Grouped archetype maps (consistent colors using your best_palette, k=7)
- Dendrogram (complete-linkage, k=7) with matching colors

## Requirements
- R >= 4.2
- Internet access for installing CRAN packages (first run)
- SE3 outputs available:
  - SOM_analysis/data/models/som2_selections/som2_selection.rds
  - SOM_analysis/data/models/som_files/cell_to_archetype_map.rds
  - SOM_analysis/data/models/som_files/spatial_reference_fromID.rds

## One-command run
From the repository root (or from within `SOM_analysis`), run:

```bash
Rscript SOM_analysis/scripts/figures/run_se4.R --config SOM_analysis/config/figures_config.yaml
