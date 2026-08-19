## Bulk RNA-seq: retrieve and explore senescence counts from recount3.
## Run this script from the repository root.

library(recount3)
source("scripts/helpers.R")
ensure_output_directories()

## Find the study -------------------------------------------------------------

human_projects <- available_projects(organism = "human")
project_info <- subset(human_projects, project == "ERP021140")
stopifnot(nrow(project_info) == 1L)

project_info[, c("project", "project_type", "n_samples")]

# DISCUSS:
# What are the advantages and limitations of uniformly processed resources such
# as recount3 compared with downloading and processing FASTQ files ourselves?
# How many samples does recount3 report for this study?

## Create a gene-level RangedSummarizedExperiment -----------------------------

rse_senescence <- create_rse(project_info, type = "gene")
rse_senescence

# A SummarizedExperiment keeps measurements, sample metadata, and feature
# annotations aligned in one object.
assay(rse_senescence)[1:5, 1:5]
head(colData(rse_senescence))
head(rowRanges(rse_senescence))
dim(rse_senescence)

# DISCUSS:
# Which dimension represents genes and which represents biological samples?
# Why is keeping annotations attached to the count matrix safer than managing
# three unrelated files?

## Convert coverage to read counts --------------------------------------------

# recount3's default assay is base-pair coverage. DESeq2 expects fragment/read
# counts, which recount3 can calculate from the stored coverage.
assay(rse_senescence, "counts") <- compute_read_counts(rse_senescence)
assayNames(rse_senescence)

saveRDS(rse_senescence, "data/derived/rse_senescence.rds")
message("Saved data/derived/rse_senescence.rds")
