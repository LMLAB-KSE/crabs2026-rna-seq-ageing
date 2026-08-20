# Data

Source data are downloaded into `data/raw/` by:

```r
source("scripts/download_data.R")
```

The script retrieves:

- `E-MTAB-5403.sdrf.txt`: ArrayExpress sample metadata for the human cellular
  senescence study ([E-MTAB-5403](https://www.ebi.ac.uk/biostudies/arrayexpress/studies/E-MTAB-5403)).
- `GSE232309_age.combined.RDS.gz`: the processed mouse ovarian ageing Seurat
  object from [GSE232309](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE232309).

The ovarian download has two gzip layers: the submitted RDS was compressed and
GEO added a second `.gz` wrapper. The workshop helper reads both layers directly,
avoiding a second approximately 1 GB copy on disk. Use the single-cell scripts
rather than calling `readRDS(gzfile(...))` yourself.

Files in `data/raw/` and `data/derived/` are intentionally excluded from Git.
The analysis scripts create derived checkpoints when needed.
