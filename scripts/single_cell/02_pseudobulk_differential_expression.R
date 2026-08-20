## Single-cell RNA-seq: age-associated pseudo-bulk differential expression.

library(Seurat)
library(DESeq2)
library(data.table)
library(ggplot2)
library(ggrepel)
source("scripts/helpers.R")
ensure_output_directories()
ovary_path <- "data/raw/GSE232309_age.combined.RDS.gz"
require_file(ovary_path, "Run scripts/download_data.R first.")

message("Loading the ovarian object; this can take a minute...")
ovary <- read_nested_gzip_rds(ovary_path)
DefaultAssay(ovary) <- "RNA"

required_columns <- c("cluster.names", "orig.ident", "age")
stopifnot(all(required_columns %in% colnames(ovary[[]])))

## Define biological replicate groups ----------------------------------------

cell_md <- ovary[[]]
group_md <- unique(cell_md[, required_columns])
colnames(group_md) <- c("cell_type", "sample", "age")
group_md <- group_md[order(group_md$cell_type, group_md$sample), ]
group_md$pseudobulk_id <- sprintf("PB%03d", seq_len(nrow(group_md)))

key <- paste(cell_md$cluster.names, cell_md$orig.ident, cell_md$age, sep = "\r")
group_key <- paste(group_md$cell_type, group_md$sample, group_md$age, sep = "\r")
ovary$pseudobulk_id <- group_md$pseudobulk_id[match(key, group_key)]
stopifnot(!anyNA(ovary$pseudobulk_id))

cell_counts <- table(ovary$pseudobulk_id)
group_md$n_cells <- as.integer(cell_counts[group_md$pseudobulk_id])
table(group_md$age, group_md$sample)

# DISCUSS BEFORE AGGREGATION:
# What is the experimental unit for the age comparison: a cell or a mouse?
# Why do thousands of cells from one mouse not become thousands of independent
# biological replicates?

## Aggregate raw counts -------------------------------------------------------

aggregated <- AggregateExpression(
  ovary, assays = "RNA", group.by = "pseudobulk_id", slot = "counts",
  return.seurat = FALSE, verbose = FALSE
)$RNA
aggregated <- round(aggregated)

if (!setequal(colnames(aggregated), group_md$pseudobulk_id)) {
  stop("Aggregated matrix columns do not match pseudo-bulk metadata.")
}
group_md <- group_md[match(colnames(aggregated), group_md$pseudobulk_id), ]
rownames(group_md) <- group_md$pseudobulk_id
stopifnot(identical(colnames(aggregated), rownames(group_md)))

saveRDS(
  list(counts = aggregated, metadata = group_md),
  "data/derived/ovary_pseudobulk_counts.rds"
)
fwrite(as.data.table(group_md), "results/tables/ovary_pseudobulk_samples.csv")

# DISCUSS:
# Why must aggregation include cell type, biological sample, and age? What would
# be lost if all young cells and all old cells were collapsed into only two
# columns?

## Endothelial pseudo-bulk DESeq2 analysis -----------------------------------

cell_type_of_interest <- "Endothelium"
minimum_cells <- 20L
keep_samples <- group_md$cell_type == cell_type_of_interest &
  group_md$n_cells >= minimum_cells
endo_counts <- aggregated[, keep_samples, drop = FALSE]
endo_md <- droplevels(group_md[keep_samples, , drop = FALSE])
endo_md$age <- relevel(factor(endo_md$age), ref = "YOUNG")

if (ncol(endo_counts) < 4L || any(table(endo_md$age) < 2L)) {
  stop("Too few endothelial biological replicates remain for DESeq2.")
}
table(endo_md$age)

dds_endo <- DESeqDataSetFromMatrix(
  countData = endo_counts, colData = endo_md, design = ~ age
)
smallest_group <- min(table(dds_endo$age))
dds_endo <- dds_endo[rowSums(counts(dds_endo) >= 10) >= smallest_group, ]
dds_endo <- DESeq(dds_endo)
resultsNames(dds_endo)

endo_result <- results(dds_endo, contrast = c("age", "OLD", "YOUNG"), alpha = 0.05)
endo_result <- as.data.table(endo_result, keep.rownames = "gene")
endo_result[, regulation := classify_de(padj, log2FoldChange)]
endo_result[, method := "pseudobulk_DESeq2"]
table(endo_result$regulation)
fwrite(endo_result, "results/tables/ovary_endothelium_pseudobulk_de.csv")
saveRDS(endo_result, "data/derived/ovary_endothelium_pseudobulk_de.rds")

p_pseudobulk <- ggplot(
  endo_result, aes(log2FoldChange, -log10(padj), colour = regulation)
) +
  geom_point(alpha = 0.7, size = 1) +
  geom_vline(xintercept = c(-log2(1.5), log2(1.5)), linetype = "dashed") +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
  scale_colour_manual(values = c(DOWN = "royalblue3", NS = "grey80", UP = "firebrick3")) +
  labs(
    title = "Endothelium: old versus young (pseudo-bulk)",
    x = "log2 fold change", y = "-log10(FDR)"
  ) +
  theme_bw()
print(p_pseudobulk)
save_plot("ovary_endothelium_pseudobulk_volcano.png", p_pseudobulk)

## Compare with a naive cell-level test --------------------------------------

Idents(ovary) <- "cluster.names"
endo_naive <- FindMarkers(
  ovary,
  ident.1 = "OLD",
  ident.2 = "YOUNG",
  group.by = "age",
  subset.ident = cell_type_of_interest,
  features = rownames(dds_endo),
  min.pct = 0,
  logfc.threshold = 0,
  test.use = "wilcox",
  verbose = FALSE
)
endo_naive <- as.data.table(endo_naive, keep.rownames = "gene")
endo_naive[, FDR := p.adjust(p_val, method = "BH")]
endo_naive[, regulation := classify_de(FDR, avg_log2FC)]
endo_naive[, method := "naive_cell_level_Wilcoxon"]

comparison <- rbindlist(list(
  endo_result[, .(method, gene, regulation)],
  endo_naive[, .(method, gene, regulation)]
))
comparison_counts <- dcast(comparison, method ~ regulation, fun.aggregate = length)
comparison_counts
fwrite(comparison_counts, "results/tables/ovary_de_method_comparison.csv")
fwrite(endo_naive, "results/tables/ovary_endothelium_naive_cell_level_de.csv")

# DISCUSS:
# How do the numbers of DE genes differ? Which assumptions of the naive test are
# violated? A smaller pseudo-bulk list is not a failure: it reflects inference
# across independent animals rather than pseudo-replication across cells.

## Optional extension to other cell types ------------------------------------

eligible <- as.data.table(group_md)[
  n_cells >= minimum_cells,
  .(replicates = .N),
  by = .(cell_type, age)
]
eligible_wide <- dcast(eligible, cell_type ~ age, value.var = "replicates", fill = 0)
age_columns <- intersect(c("YOUNG", "OLD"), names(eligible_wide))
eligible_wide[
  apply(eligible_wide[, ..age_columns] >= 2, 1, all)
]

# The aggregation and DESeq2 block above can be wrapped in a function and
# applied to cell types with at least two adequately sized replicates per age.
# Keep this optional: multiple cell types also require correction across the
# expanded family of tests and careful interpretation of cell abundance.
