## Optional bulk RNA-seq extension: Gene Ontology over-representation.
## Replace each YOUR_CODE_HERE expression, using the surrounding comments.

library(data.table)
library(clusterProfiler)
library(enrichplot)
library(org.Hs.eg.db)
library(ggplot2)
source("scripts/helpers.R")
ensure_output_directories()
require_file(
  "data/derived/bulk_de_results.rds",
  "Run scripts/bulk/05_differential_expression.R first."
)

deg <- readRDS("data/derived/bulk_de_results.rds")

## Define foreground and background correctly --------------------------------

# We examine genes that are significant in at least one post-irradiation
# contrast. The universe contains all tested genes with a valid symbol, not the
# whole genome.
universe <- unique(na.omit(YOUR_CODE_HERE))
up_genes <- unique(na.omit(YOUR_CODE_HERE))
down_genes <- unique(na.omit(YOUR_CODE_HERE))

run_go <- function(genes) {
  enrichGO(
    gene = YOUR_CODE_HERE, universe = YOUR_CODE_HERE, OrgDb = YOUR_CODE_HERE,
    keyType = YOUR_CODE_HERE, ont = "BP", pAdjustMethod = "BH",
    pvalueCutoff = 0.05, qvalueCutoff = 0.2, readable = TRUE
  )
}

go_up <- run_go(up_genes)
go_down <- run_go(down_genes)

# DISCUSS:
# Why must the background contain genes that could have been called as DEGs?
# What bias would using every annotated human gene introduce?

simplify_go <- function(result) {
  if (nrow(as.data.frame(result)) == 0L) return(result)
  simplify(result, cutoff = 0.7, by = "p.adjust", select_fun = min)
}
go_up <- simplify_go(go_up)
go_down <- simplify_go(go_down)

fwrite(as.data.table(as.data.frame(go_up)), "results/tables/go_upregulated.csv")
fwrite(as.data.table(as.data.frame(go_down)), "results/tables/go_downregulated.csv")
saveRDS(list(up = go_up, down = go_down), "data/derived/bulk_go_results.rds")

if (nrow(as.data.frame(go_up)) > 0L) {
  p_up <- dotplot(go_up, showCategory = 20) + ggtitle("Up-regulated genes")
  print(p_up)
  save_plot("bulk_go_upregulated.png", p_up, width = 9, height = 7)
}
if (nrow(as.data.frame(go_down)) > 0L) {
  p_down <- dotplot(go_down, showCategory = 20) + ggtitle("Down-regulated genes")
  print(p_down)
  save_plot("bulk_go_downregulated.png", p_down, width = 9, height = 7)
}

# DISCUSS:
# Which enriched processes are consistent with irradiation-induced senescence?
# Are the terms redundant, and how does semantic simplification affect the
# biological story? Enrichment is association, not evidence of causation.
