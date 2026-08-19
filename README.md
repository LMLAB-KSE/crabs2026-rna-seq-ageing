# RNA-seq and ageing in R

This repository contains a hands-on introduction to differential expression in
bulk and single-cell RNA-seq. The examples use an irradiation-induced cellular
senescence study and a mouse ovarian ageing atlas.

The material is a tutorial, not a graded assignment. Pause at the `DISCUSS`
prompts, inspect the output, and choose how much code you want to complete
yourself:

- `main` contains the complete, runnable workflow.
- `exercises` contains the same explanations with selected code replaced by
  `YOUR_CODE_HERE`.

You can switch branches at any time. Downloaded data and generated results are
ignored by Git and remain available after switching.

## Before the workshop

Use a computer with at least 16 GB RAM and approximately 10 GB free disk space.
Install R 4.5.x and RStudio Desktop (recommended), then follow the operating-
system requirements in [setup/README.md](setup/README.md).

Clone this repository, open `crabs2026-rna-seq-ageing.Rproj`, and run:

```r
source("scripts/setup.R")
source("scripts/check_setup.R")
source("scripts/download_data.R")
```

Package installation can take a while. The ovarian Seurat object is about 1 GB
to download and needs several GB of memory, so complete these steps beforehand.
If a download is interrupted, run `download_data.R` again.

## Workflow

Run scripts from the repository root and in numerical order within each topic.

### Bulk RNA-seq: cellular senescence

1. [`scripts/bulk/01_retrieve_counts.R`](scripts/bulk/01_retrieve_counts.R) —
   retrieve gene counts and learn the `SummarizedExperiment` structure.
2. [`scripts/bulk/02_prepare_metadata.R`](scripts/bulk/02_prepare_metadata.R) —
   inspect, clean, and match study metadata.
3. [`scripts/bulk/03_explore_annotations.R`](scripts/bulk/03_explore_annotations.R) —
   explore gene identifiers and annotations.
4. [`scripts/bulk/04_qc_batch_effects.R`](scripts/bulk/04_qc_batch_effects.R) —
   select samples, filter genes, perform QC, discover a batch effect, and define
   a DESeq2 design.
5. [`scripts/bulk/05_differential_expression.R`](scripts/bulk/05_differential_expression.R) —
   fit the model, test irradiation-time contrasts, and visualize DE genes.
6. [`scripts/bulk/06_go_enrichment_optional.R`](scripts/bulk/06_go_enrichment_optional.R) —
   optional Gene Ontology over-representation analysis.

### Single-cell RNA-seq: ovarian ageing

1. [`scripts/single_cell/01_explore_ovarian_data.R`](scripts/single_cell/01_explore_ovarian_data.R) —
   inspect the authors' processed Seurat object, metadata, QC, cell types, and
   processing history.
2. [`scripts/single_cell/02_pseudobulk_differential_expression.R`](scripts/single_cell/02_pseudobulk_differential_expression.R) —
   aggregate biological replicates, run DESeq2 on endothelial pseudo-bulk
   samples, and compare with a naive cell-level analysis.

The single-cell scripts intentionally do not rerun full preprocessing or
integration. Their focus is biological replication and differential expression.

## Data and outputs

- `data/raw/` contains downloaded source files.
- `data/derived/` contains reusable R checkpoints made by the scripts.
- `results/figures/` and `results/tables/` contain generated outputs.

See [data/README.md](data/README.md) for sources and download details. Existing
valid downloads are not repeated.

## Troubleshooting

Run `source("scripts/check_setup.R")` first. It reports missing packages, data,
and common platform problems. See [setup/README.md](setup/README.md) for detailed
OS-specific guidance and [`INSTRUCTOR_NOTES.md`](INSTRUCTOR_NOTES.md) for
teaching suggestions.
