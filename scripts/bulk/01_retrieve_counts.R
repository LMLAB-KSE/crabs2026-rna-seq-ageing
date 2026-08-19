## Bulk RNA-seq: retrieve and explore senescence counts from recount3.
## Run this script from the repository root.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(recount3)
source("scripts/helpers.R")
ensure_output_directories()

## Find the study -------------------------------------------------------------

human_projects <- available_projects(organism = "human")
project_info <- subset(human_projects, project == YOUR_CODE_HERE)
stopifnot(nrow(project_info) == 1L)

project_info[, c("project", "project_type", "n_samples")]

# DISCUSS:
# What are the advantages and limitations of uniformly processed resources such
# as recount3 compared with downloading and processing FASTQ files ourselves?
# How many samples does recount3 report for this study?

## Create a gene-level RangedSummarizedExperiment -----------------------------

rse_senescence <- create_rse(YOUR_CODE_HERE, type = YOUR_CODE_HERE)
rse_senescence

# A SummarizedExperiment keeps measurements, sample metadata, and feature
# annotations aligned in one object.
YOUR_CODE_HERE[1:5, 1:5]
head(YOUR_CODE_HERE)
head(YOUR_CODE_HERE)
dim(rse_senescence)

# DISCUSS:
# Which dimension represents genes and which represents biological samples?
# Why is keeping annotations attached to the count matrix safer than managing
# three unrelated files?

## Convert coverage to read counts --------------------------------------------

# recount3's default assay is base-pair coverage. DESeq2 expects fragment/read
# counts, which recount3 can calculate from the stored coverage.
assay(rse_senescence, "counts") <- YOUR_CODE_HERE
assayNames(rse_senescence)

saveRDS(rse_senescence, "data/derived/rse_senescence.rds")
message("Saved data/derived/rse_senescence.rds")
