## Bulk RNA-seq: inspect and complete sample metadata.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(recount3)
source("scripts/helpers.R")
ensure_output_directories()
require_file(
  "data/derived/rse_senescence.rds",
  "Run scripts/bulk/01_retrieve_counts.R first."
)
require_file(
  "data/raw/E-MTAB-5403.sdrf.txt",
  "Run scripts/download_data.R first."
)

rse_senescence <- readRDS("data/derived/rse_senescence.rds")

## Inspect recount3 metadata --------------------------------------------------

metadata(rse_senescence)$recount3_version
metadata(rse_senescence)$annotation
sample_md <- as.data.frame(YOUR_CODE_HERE)
table(sample_md$sra.library_selection, useNA = "ifany")
mean(sample_md[["recount_qc.star.%_mapped_reads_both"]], na.rm = TRUE)

# DISCUSS:
# Which genome annotation, RNA-selection method, and aligner were used?
# Why should these technical details be recorded before differential analysis?

## Expand SRA attributes ------------------------------------------------------

rse_senescence <- YOUR_CODE_HERE
table(colData(rse_senescence)$sra_attribute.cell_type, useNA = "ifany")

# Cell type is now available, but irradiation state is still missing. The EBI
# SDRF contains it in a study-specific field.
ebi_md <- read.delim(
  "data/raw/E-MTAB-5403.sdrf.txt", check.names = TRUE,
  stringsAsFactors = FALSE
)
colnames(ebi_md)
table(ebi_md$Factor.Value.irradiate., useNA = "ifany")

## Clean irradiation labels --------------------------------------------------

label_map <- c(
  "Quiescence" = "Quiescent",
  "Proliferation" = "Proliferating",
  "Irradiation, day 4" = "Post_IR_4",
  "Irradiation, day 10" = "Post_IR_10",
  "Irradiation, day 20" = "Post_IR_20"
)
day_map <- c(
  "Quiescence" = NA_real_, "Proliferation" = 0,
  "Irradiation, day 4" = 4, "Irradiation, day 10" = 10,
  "Irradiation, day 20" = 20
)

raw_irradiation <- ebi_md$Factor.Value.irradiate.
if (!all(raw_irradiation %in% names(label_map))) {
  stop("The SDRF contains an unexpected irradiation label.")
}
ebi_md$irr_info <- unname(label_map[YOUR_CODE_HERE])
ebi_md$irr_day <- unname(day_map[YOUR_CODE_HERE])

## Match metadata explicitly -------------------------------------------------

ebi_md <- unique(ebi_md[, c("Source.Name", "irr_info", "irr_day")])
ebi_md$sample_id <- paste0("E-MTAB-5403:", ebi_md$Source.Name)
rse_ids <- colData(rse_senescence)$sra_attribute.Alias
matched_rows <- match(YOUR_CODE_HERE, YOUR_CODE_HERE)

if (anyNA(matched_rows) || anyDuplicated(ebi_md$sample_id)) {
  stop("Sample metadata could not be matched one-to-one.")
}
ebi_md <- ebi_md[matched_rows, ]
stopifnot(identical(ebi_md$sample_id, rse_ids))

colData(rse_senescence)$irr_info <- factor(
  YOUR_CODE_HERE,
  levels = c("Proliferating", "Post_IR_4", "Post_IR_10", "Post_IR_20", "Quiescent")
)
colData(rse_senescence)$irr_day <- YOUR_CODE_HERE
table(colData(rse_senescence)$irr_info, useNA = "ifany")

# DISCUSS:
# Why did the SDRF contain twice as many rows as biological samples?
# What could go wrong if metadata were attached by row position without
# matching stable sample identifiers?

saveRDS(rse_senescence, "data/derived/rse_senescence_annotated.rds")
message("Saved data/derived/rse_senescence_annotated.rds")
