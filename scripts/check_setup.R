## Diagnose the local R environment and downloaded data.

supported_environments <- list(
  "4.5" = list(lockfile = "renv.lock.R-4.5", bioconductor = "3.22"),
  "4.6" = list(lockfile = "renv.lock", bioconductor = "3.23")
)
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
environment <- supported_environments[[current_r]]
if (is.null(environment)) {
  cat("[FAIL] Unsupported R version. Use R 4.5.x or R 4.6.x.\n")
} else {
  cat("[ OK ] Supported R version; expected Bioconductor ",
      environment$bioconductor, ".\n", sep = "")
}

selected_lockfile <- if (is.null(environment)) NA_character_ else environment$lockfile
if (is.na(selected_lockfile) || !file.exists(selected_lockfile)) {
  cat("[FAIL] Compatible lockfile is missing; are you in the repository root?\n")
} else {
  cat("[ OK ] Selected lockfile: ", selected_lockfile, ".\n", sep = "")
  if (requireNamespace("renv", quietly = TRUE)) {
    lock <- renv::lockfile_read(selected_lockfile)
    lock_r <- sub("^([0-9]+\\.[0-9]+).*$", "\\1", as.character(lock$R$Version))
    lock_bioc <- if (is.null(lock$Bioconductor$Version)) {
      NA_character_
    } else {
      as.character(lock$Bioconductor$Version)
    }
    if (identical(lock_r, current_r) &&
        identical(lock_bioc, environment$bioconductor)) {
      cat("[ OK ] Lockfile R and Bioconductor versions match.\n")
    } else {
      cat(
        "[FAIL] Lockfile metadata mismatch: found R ", lock_r,
        " / Bioconductor ", ifelse(is.na(lock_bioc), "not recorded", lock_bioc),
        "; expected R ", current_r, " / Bioconductor ",
        environment$bioconductor, ".\n", sep = ""
      )
    }
  }
}

check_packages <- function(packages, required) {
  # Some compatible Bioconductor packages emit namespace replacement warnings
  # while loading. They are not installation failures, so keep this diagnostic
  # focused on whether each namespace can be loaded successfully.
  installed <- vapply(
    packages,
    function(package) suppressWarnings(requireNamespace(package, quietly = TRUE)),
    logical(1)
  )
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
