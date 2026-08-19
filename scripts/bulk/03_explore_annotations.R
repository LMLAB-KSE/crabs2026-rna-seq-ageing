## Bulk RNA-seq: explore gene annotations.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(SummarizedExperiment)
source("scripts/helpers.R")
require_file(
  "data/derived/rse_senescence_annotated.rds",
  "Run scripts/bulk/02_prepare_metadata.R first."
)

rse_senescence <- readRDS("data/derived/rse_senescence_annotated.rds")
gene_anno <- YOUR_CODE_HERE

gene_anno
length(gene_anno)
head(names(gene_anno))
ranges(YOUR_CODE_HERE)
YOUR_CODE_HERE
head(sort(table(YOUR_CODE_HERE), decreasing = TRUE), 10)

# DISCUSS:
# Which identifier convention is used for row names? What does the suffix after
# the dot represent? Why should analyses avoid assuming every Ensembl gene has
# a unique HGNC symbol?
# Which three gene biotypes are most abundant in this annotation?
