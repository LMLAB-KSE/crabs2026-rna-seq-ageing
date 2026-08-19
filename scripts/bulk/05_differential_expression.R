## Bulk RNA-seq: batch-adjusted differential expression with DESeq2.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(DESeq2)
library(apeglm)
library(data.table)
library(ComplexUpset)
library(ggplot2)
library(ggrepel)
source("scripts/helpers.R")
ensure_output_directories()
require_file(
  "data/derived/dds_senescence.rds",
  "Run scripts/bulk/04_qc_batch_effects.R first."
)

dds_senescence <- readRDS("data/derived/dds_senescence.rds")

## Fit the model --------------------------------------------------------------

dds_senescence$irr_info <- relevel(YOUR_CODE_HERE, ref = YOUR_CODE_HERE)
design(dds_senescence) <- YOUR_CODE_HERE
dds_senescence <- YOUR_CODE_HERE
resultsNames(dds_senescence)

png("results/figures/bulk_dispersion_estimates.png", width = 1200, height = 900, res = 150)
plotDispEsts(dds_senescence)
dev.off()

# DISCUSS:
# What do the black points, red trend, and blue outliers in the dispersion plot
# represent? Why is overdispersion expected in RNA-seq counts?

## Test post-irradiation time points ------------------------------------------

time_points <- c("Post_IR_4", "Post_IR_10", "Post_IR_20")
deg_tables <- lapply(time_points, function(time_point) {
  coefficient <- paste0("irr_info_", time_point, "_vs_Proliferating")
  stopifnot(coefficient %in% resultsNames(dds_senescence))
  result <- results(dds_senescence, contrast = YOUR_CODE_HERE, alpha = 0.05)
  result <- lfcShrink(
    dds_senescence, coef = YOUR_CODE_HERE, res = result, type = "apeglm"
  )
  table <- as.data.table(result, keep.rownames = "gene_id")
  table[, gene_name := rowRanges(dds_senescence)$gene_name]
  table[, gene_type := rowRanges(dds_senescence)$gene_type]
  table[, time_point := time_point]
  table[, regulation := classify_de(YOUR_CODE_HERE, YOUR_CODE_HERE)]
  table
})
deg <- rbindlist(deg_tables)

deg_counts <- dcast(deg, time_point ~ regulation, fun.aggregate = length)
deg_counts
fwrite(deg_counts, "results/tables/bulk_de_gene_counts.csv")
fwrite(deg, "results/tables/bulk_de_results.csv")
saveRDS(deg, "data/derived/bulk_de_results.rds")

# DISCUSS:
# At which time point do the largest expression changes appear? Does the
# response look immediate or progressive? Why apply both an FDR and an effect-
# size threshold?

## Gene-set overlap -----------------------------------------------------------

make_membership <- function(direction) {
  selected <- unique(deg[regulation == direction, .(gene_id, time_point)])
  dcast(
    selected, gene_id ~ time_point, fun.aggregate = length,
    value.var = "time_point"
  )
}

for (direction in c("UP", "DOWN")) {
  membership <- make_membership(direction)
  plot <- upset(
    membership, intersect = time_points,
    name = paste(direction, "genes"), width_ratio = 0.2
  )
  print(plot)
  save_plot(
    paste0("bulk_de_upset_", tolower(direction), ".png"), plot,
    width = 9, height = 5
  )
}

## Volcano and MA plots -------------------------------------------------------

change_colours <- c(DOWN = "royalblue3", NS = "grey80", UP = "firebrick3")

make_volcano <- function(table, title) {
  labels <- table[!is.na(padj)][order(padj)][seq_len(min(15L, sum(!is.na(padj))))]
  ggplot(table, aes(log2FoldChange, -log10(padj), colour = regulation)) +
    geom_point(alpha = 0.75, size = 1) +
    geom_vline(xintercept = c(-log2(1.5), log2(1.5)), linetype = "dashed") +
    geom_hline(yintercept = -log10(0.05), linetype = "dashed") +
    geom_text_repel(
      data = labels, aes(label = gene_name), size = 3,
      max.overlaps = 15, show.legend = FALSE
    ) +
    scale_colour_manual(values = change_colours) +
    labs(title = title, x = "Shrunken log2 fold change", y = "-log10(FDR)") +
    theme_bw() + theme(legend.position = "bottom")
}

make_ma <- function(table, title) {
  ggplot(table, aes(baseMean, log2FoldChange, colour = regulation)) +
    geom_point(alpha = 0.65, size = 1) +
    geom_hline(yintercept = c(-log2(1.5), 0, log2(1.5)),
               linetype = c("dashed", "solid", "dashed")) +
    scale_x_log10() +
    scale_colour_manual(values = change_colours) +
    coord_cartesian(ylim = c(-3, 3)) +
    labs(title = title, x = "Mean normalized count", y = "Shrunken log2 fold change") +
    theme_bw() + theme(legend.position = "bottom")
}

for (selected_time_point in time_points) {
  table <- deg[deg$time_point == selected_time_point]
  label <- sub("Post_IR_", "Day ", selected_time_point)
  volcano <- make_volcano(table, paste(label, "versus proliferating"))
  ma <- make_ma(table, paste(label, "versus proliferating"))
  print(volcano)
  print(ma)
  save_plot(paste0("bulk_de_volcano_", selected_time_point, ".png"), volcano)
  save_plot(paste0("bulk_de_ma_", selected_time_point, ".png"), ma)
}

# DISCUSS:
# Why are volcano and MA plots complementary? Which gene is the most significant
# up-regulated gene four days after irradiation, and is its known biology
# consistent with senescence?

top_day4_up <- deg[
  time_point == "Post_IR_4" & regulation == "UP"
][order(padj)][1]
top_day4_up
