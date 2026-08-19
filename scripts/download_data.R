## Download source metadata and the processed ovarian Seurat object.

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
options(timeout = max(3600, getOption("timeout")))

downloads <- data.frame(
  label = c("senescence metadata", "ovarian Seurat object"),
  url = c(
    "https://www.ebi.ac.uk/biostudies/files/E-MTAB-5403/E-MTAB-5403.sdrf.txt",
    paste0(
      "https://ftp.ncbi.nlm.nih.gov/geo/series/GSE232nnn/GSE232309/suppl/",
      "GSE232309_age.combined.RDS.gz"
    )
  ),
  destination = c(
    "data/raw/E-MTAB-5403.sdrf.txt",
    "data/raw/GSE232309_age.combined.RDS.gz"
  ),
  minimum_bytes = c(1000, 900 * 1024^2),
  stringsAsFactors = FALSE
)

download_one <- function(label, url, destination, minimum_bytes) {
  if (file.exists(destination) && file.info(destination)$size >= minimum_bytes) {
    message("Already present: ", label, " (", destination, ")")
    return(invisible(destination))
  }
  if (file.exists(destination)) {
    message("Removing an incomplete file: ", destination)
    unlink(destination)
  }

  temporary <- paste0(destination, ".download")
  on.exit(if (file.exists(temporary)) unlink(temporary), add = TRUE)
  message("Downloading ", label, "...")
  status <- tryCatch(
    utils::download.file(url, temporary, mode = "wb", method = "libcurl"),
    error = function(error) error
  )
  if (inherits(status, "error") || !file.exists(temporary)) {
    stop(
      "Download failed for ", label, ".\nURL: ", url,
      "\nCheck your connection and rerun this script.\n",
      if (inherits(status, "error")) conditionMessage(status) else "No file received."
    )
  }
  if (file.info(temporary)$size < minimum_bytes) {
    stop("Downloaded file is unexpectedly small: ", temporary)
  }
  if (!file.rename(temporary, destination)) {
    stop("Could not move the completed download to ", destination)
  }
  message("Saved ", destination, " (",
          format(file.info(destination)$size / 1024^2, digits = 4), " MB).")
  invisible(destination)
}

for (i in seq_len(nrow(downloads))) {
  download_one(
    downloads$label[[i]], downloads$url[[i]], downloads$destination[[i]],
    downloads$minimum_bytes[[i]]
  )
}

message("All source data are available. Run scripts/check_setup.R to verify.")
