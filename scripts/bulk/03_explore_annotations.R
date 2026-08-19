## Bulk RNA-seq: explore gene annotations.

library(SummarizedExperiment)
source("scripts/helpers.R")
require_file(
  "data/derived/rse_senescence_annotated.rds",
  "Run scripts/bulk/02_prepare_metadata.R first."
)

rse_senescence <- readRDS("data/derived/rse_senescence_annotated.rds")
gene_anno <- rowRanges(rse_senescence)

gene_anno
length(gene_anno)
head(names(gene_anno))
ranges(gene_anno["ENSG00000224496.7"])
gene_anno["ENSG00000224496.7"]$gene_name
head(sort(table(gene_anno$gene_type), decreasing = TRUE), 10)

# DISCUSS:
# Which identifier convention is used for row names? What does the suffix after
# the dot represent? Why should analyses avoid assuming every Ensembl gene has
# a unique HGNC symbol?
# Which three gene biotypes are most abundant in this annotation?
