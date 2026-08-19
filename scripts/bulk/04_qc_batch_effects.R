## Bulk RNA-seq: sample selection, filtering, QC, and batch effects.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(DESeq2)
library(ggplot2)
library(pheatmap)
library(RColorBrewer)
source("scripts/helpers.R")
ensure_output_directories()
require_file(
  "data/derived/rse_senescence_annotated.rds",
  "Run scripts/bulk/02_prepare_metadata.R first."
)

rse_senescence <- readRDS("data/derived/rse_senescence_annotated.rds")

## Select the biological comparison ------------------------------------------

table(colData(rse_senescence)$sra_attribute.cell_type)
rse_senescence <- rse_senescence[, YOUR_CODE_HERE]
rse_senescence <- rse_senescence[, !is.na(rse_senescence$irr_day)]
rse_senescence$irr_info <- droplevels(rse_senescence$irr_info)
table(rse_senescence$irr_info)

# DESeqDataSet() uses the assay named "counts" when constructed explicitly.
dds_initial <- DESeqDataSetFromMatrix(
  countData = YOUR_CODE_HERE,
  colData = YOUR_CODE_HERE,
  design = YOUR_CODE_HERE
)
rowRanges(dds_initial) <- rowRanges(rse_senescence)

## Filter low-expression genes -----------------------------------------------

smallest_group_size <- YOUR_CODE_HERE
keep <- YOUR_CODE_HERE
dds_initial <- dds_initial[keep, ]
cat("Genes retained:", nrow(dds_initial), "\n")
head(sort(table(rowRanges(dds_initial)$gene_type), decreasing = TRUE))

# DISCUSS:
# Why is the smallest biological group size a defensible filtering threshold?
# How many samples and genes remain? How many retained genes are protein coding?

## Unsupervised QC ------------------------------------------------------------

# blind=TRUE prevents the experimental design from influencing the variance
# trend. This is appropriate when using the transform for unbiased sample QC.
vsd_initial <- vst(dds_initial, blind = YOUR_CODE_HERE)
pca_initial <- plotPCA(vsd_initial, intgroup = "irr_info", returnData = TRUE)
percent_var <- round(100 * attr(pca_initial, "percentVar"))

p_pca <- ggplot(pca_initial, aes(PC1, PC2, colour = irr_info, label = name)) +
  geom_point(size = 3) +
  ggrepel::geom_text_repel(show.legend = FALSE, size = 3) +
  labs(
    x = paste0("PC1: ", percent_var[[1]], "% variance"),
    y = paste0("PC2: ", percent_var[[2]], "% variance"), colour = "State"
  ) +
  theme_bw()
print(p_pca)
save_plot("bulk_qc_pca_before_batch.png", p_pca)

sample_dists <- dist(t(assay(vsd_initial)))
sample_annotation <- as.data.frame(colData(vsd_initial)[, "irr_info", drop = FALSE])
png("results/figures/bulk_sample_distances.png", width = 1400, height = 1200, res = 160)
pheatmap(
  as.matrix(sample_dists), clustering_distance_rows = sample_dists,
  clustering_distance_cols = sample_dists,
  color = colorRampPalette(rev(brewer.pal(9, "Blues")))(255),
  annotation_col = sample_annotation
)
dev.off()

# DISCUSS BEFORE CONTINUING:
# What likely drives PC1? What might drive PC2? Do samples cluster only by the
# intended biological condition? Which evidence suggests a technical effect?

## Encode the documented researcher batch -----------------------------------

# The original investigators confirmed that keratinocyte samples were handled
# by two researchers. In this dataset PC2 separates those batches. We use the
# sign of PC2 to reproduce the documented labels, while checking sample order.
stopifnot(identical(rownames(pca_initial), colnames(rse_senescence)))
rse_senescence$batch <- factor(YOUR_CODE_HERE)
table(rse_senescence$irr_info, rse_senescence$batch)

# DISCUSS:
# Is batch confounded with irradiation state? What would happen if every control
# sample were in one batch and every irradiated sample in the other?

dds_senescence <- DESeqDataSetFromMatrix(
  countData = round(assay(rse_senescence, "counts")),
  colData = as.data.frame(colData(rse_senescence)),
  design = YOUR_CODE_HERE
)
rowRanges(dds_senescence) <- rowRanges(rse_senescence)
dds_senescence <- dds_senescence[keep, ]

# Statistical testing retains raw counts and accounts for batch in the design.
# Merely adding batch to the design does not remove it from a blind QC
# transformation; visual batch correction is a distinct operation.

saveRDS(dds_senescence, "data/derived/dds_senescence.rds")
message("Saved data/derived/dds_senescence.rds")
