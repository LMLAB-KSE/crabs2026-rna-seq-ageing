## Single-cell RNA-seq: explore the processed ovarian ageing Seurat object.

library(Seurat)
library(ggplot2)
source("scripts/helpers.R")
ensure_output_directories()
ovary_path <- "data/raw/GSE232309_age.combined.RDS.gz"
require_file(ovary_path, "Run scripts/download_data.R first.")

message("Loading the ovarian object; this can take a minute...")
ovary <- read_nested_gzip_rds(ovary_path)
stopifnot(inherits(ovary, "Seurat"))

## Learn the object structure -------------------------------------------------

ovary
Assays(ovary)
DefaultAssay(ovary)
Layers(ovary[[DefaultAssay(ovary)]])
Reductions(ovary)
head(Cells(ovary))
head(Features(ovary))

cell_md <- ovary[[]]
str(cell_md)

required_columns <- c("cluster.names", "orig.ident", "age")
if (!all(required_columns %in% colnames(cell_md))) {
  stop(
    "Expected metadata columns are missing: ",
    paste(setdiff(required_columns, colnames(cell_md)), collapse = ", ")
  )
}

# DISCUSS:
# What is stored in an assay, a layer, cell metadata, and a dimensional
# reduction? Why can one Seurat object contain several assays or layers?

## Samples, ages, and cell types ---------------------------------------------

table(cell_md$age, cell_md$orig.ident)
sort(table(cell_md$cluster.names), decreasing = TRUE)
sample_summary <- unique(cell_md[, c("orig.ident", "age")])
sample_summary[order(sample_summary$age, sample_summary$orig.ident), ]

# DISCUSS:
# How many biological replicates are available in each age group? Which mouse
# strain was used in the study? Which cell types are rare, and why can rarity
# matter for pseudo-bulk analysis?

## Inspect QC information ----------------------------------------------------

qc_columns <- intersect(
  c("nCount_RNA", "nFeature_RNA", "percent.mt", "percent.mt_RNA"),
  colnames(cell_md)
)
summary(cell_md[, qc_columns, drop = FALSE])

if (all(c("nCount_RNA", "nFeature_RNA") %in% qc_columns)) {
  p_qc <- FeatureScatter(
    ovary, feature1 = "nCount_RNA", feature2 = "nFeature_RNA"
  ) + theme_bw()
  print(p_qc)
  save_plot("ovary_qc_counts_vs_features.png", p_qc)
}

# DISCUSS:
# What do UMI count, detected-gene count, and mitochondrial percentage reveal
# about cell quality? Why should thresholds depend on the tissue and protocol?

## Visualize supplied embeddings and processing history ----------------------

if (!"umap" %in% Reductions(ovary)) {
  stop("The expected UMAP reduction is absent from the downloaded object.")
}
p_cell_type <- DimPlot(
  ovary, reduction = "umap", group.by = "cluster.names", label = TRUE,
  repel = TRUE
) + NoLegend()
p_age <- DimPlot(ovary, reduction = "umap", group.by = "age")
print(p_cell_type)
print(p_age)
save_plot("ovary_umap_cell_types.png", p_cell_type, width = 10, height = 7)
save_plot("ovary_umap_age.png", p_age, width = 8, height = 6)

names(ovary@commands)
ovary@commands

# DISCUSS:
# Which preprocessing operations did the authors record? Was an integration
# command recorded? According to the article, why did the authors choose their
# integration strategy? What can and cannot be concluded from overlap on UMAP?

summary_checkpoint <- list(
  dimensions = dim(ovary), assays = Assays(ovary), reductions = Reductions(ovary),
  samples = sample_summary,
  cells_per_type = sort(table(cell_md$cluster.names), decreasing = TRUE)
)
saveRDS(summary_checkpoint, "data/derived/ovary_object_summary.rds")
message("Saved data/derived/ovary_object_summary.rds")
