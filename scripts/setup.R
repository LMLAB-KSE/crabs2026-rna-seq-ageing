## Restore the reproducible R environment.

required_r <- "4.5"
current_r <- paste(R.version$major, strsplit(R.version$minor, "\\.")[[1]][1], sep = ".")

if (!identical(current_r, required_r)) {
  warning(
    "This project is tested with R 4.5.x; you are using R ",
    getRversion(), ". Package binaries or the lockfile may be incompatible."
  )
}

options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("renv", quietly = TRUE)) {
  message("Installing renv from CRAN...")
  install.packages("renv")
}

if (!file.exists("renv.lock")) {
  stop("renv.lock is missing. Make sure R is running from the repository root.")
}

message("Restoring packages recorded in renv.lock. This can take some time...")
renv::consent(provided = TRUE)
renv::restore(prompt = FALSE)
message("Package restore complete. Run source('scripts/check_setup.R') next.")
