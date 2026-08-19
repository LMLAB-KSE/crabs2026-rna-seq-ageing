## Diagnose the local R environment and downloaded data.

required_r <- "4.5"
core_packages <- c(
  "recount3", "DESeq2", "apeglm", "Seurat", "data.table",
  "ggplot2", "ggrepel", "pheatmap", "RColorBrewer", "ComplexUpset"
)
optional_packages <- c("clusterProfiler", "enrichplot", "org.Hs.eg.db")

cat("RNA-seq workshop setup check\n")
cat("============================\n")
cat("R version: ", as.character(getRversion()), "\n", sep = "")
cat("Platform:  ", R.version$platform, "\n", sep = "")

current_r <- paste(R.version$major, strsplit(R.version$minor, "\\.")[[1]][1], sep = ".")
if (!identical(current_r, required_r)) {
  cat("[WARN] Expected R 4.5.x.\n")
} else {
  cat("[ OK ] Supported R version.\n")
}

if (!file.exists("renv.lock")) {
  cat("[FAIL] renv.lock is missing; are you in the repository root?\n")
} else {
  cat("[ OK ] renv.lock found.\n")
}

check_packages <- function(packages, required) {
  installed <- vapply(packages, requireNamespace, logical(1), quietly = TRUE)
  label <- if (required) "required" else "optional GO"
  if (all(installed)) {
    cat("[ OK ] All ", label, " packages are installed.\n", sep = "")
  } else {
    cat("[", if (required) "FAIL" else "WARN", "] Missing ", label,
        " packages: ", paste(packages[!installed], collapse = ", "), "\n", sep = "")
  }
  invisible(installed)
}

core_ok <- check_packages(core_packages, required = TRUE)
check_packages(optional_packages, required = FALSE)

data_files <- c(
  "senescence metadata" = "data/raw/E-MTAB-5403.sdrf.txt",
  "ovarian Seurat object" = "data/raw/GSE232309_age.combined.RDS.gz"
)
for (label in names(data_files)) {
  path <- unname(data_files[[label]])
  if (file.exists(path) && file.info(path)$size > 0) {
    cat("[ OK ] ", label, ": ", path, " (",
        format(file.info(path)$size / 1024^2, digits = 4), " MB)\n", sep = "")
  } else {
    cat("[WARN] Missing ", label, ". Run source('scripts/download_data.R').\n", sep = "")
  }
}

for (path in c("data/raw", "data/derived", "results/figures", "results/tables")) {
  writable <- dir.exists(path) && file.access(path, 2) == 0
  cat(if (writable) "[ OK ] " else "[FAIL] ", path,
      if (writable) " is writable.\n" else " is not writable.\n", sep = "")
}

if (!all(core_ok)) {
  cat("\nRun source('scripts/setup.R') and consult setup/README.md.\n")
} else {
  cat("\nCore environment check passed. Warnings above may still need attention.\n")
}
