## Small shared helpers used by analysis scripts.

require_file <- function(path, instruction = NULL) {
  if (!file.exists(path)) {
    message <- paste0("Required file is missing: ", path)
    if (!is.null(instruction)) message <- paste(message, instruction, sep = "\n")
    stop(message, call. = FALSE)
  }
  invisible(path)
}

ensure_output_directories <- function() {
  directories <- c("data/derived", "results/figures", "results/tables")
  invisible(lapply(directories, dir.create, recursive = TRUE, showWarnings = FALSE))
}

read_nested_gzip_rds <- function(path) {
  # The GEO ovarian download has two compression layers: the submitted RDS was
  # gzip-compressed by saveRDS(), then GEO distributed it inside another .gz
  # wrapper. A nested connection removes both layers without creating another
  # approximately 1 GB file on disk.
  require_file(path)
  outer_connection <- gzfile(path, open = "rb")
  inner_connection <- gzcon(outer_connection)
  on.exit(close(inner_connection), add = TRUE)
  readRDS(inner_connection)
}

save_plot <- function(filename, plot, width = 8, height = 6) {
  ggplot2::ggsave(
    filename = file.path("results/figures", filename), plot = plot,
    width = width, height = height, units = "in", dpi = 160
  )
}

classify_de <- function(padj, log2_fold_change, fdr = 0.05, fold_change = 1.5) {
  threshold <- log2(fold_change)
  ifelse(
    !is.na(padj) & padj <= fdr & log2_fold_change >= threshold, "UP",
    ifelse(
      !is.na(padj) & padj <= fdr & log2_fold_change <= -threshold, "DOWN", "NS"
    )
  )
}
