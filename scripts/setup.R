## Restore the reproducible R environment.

current_r <- paste(R.version$major, strsplit(R.version$minor, "\\.")[[1]][1], sep = ".")
environments <- list(
  "4.5" = list(lockfile = "renv.lock.R-4.5", bioconductor = "3.22"),
  "4.6" = list(lockfile = "renv.lock", bioconductor = "3.23")
)

environment <- environments[[current_r]]
if (is.null(environment)) {
  stop(
    "Unsupported R version ", getRversion(), ".\n",
    "This workshop supports R 4.5.x and R 4.6.x. Install one of these ",
    "versions and restart R before running setup."
  )
}

options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("renv", quietly = TRUE)) {
  message("Installing renv from CRAN...")
  install.packages("renv")
}

if (!file.exists(environment$lockfile)) {
  stop(
    "The lockfile for R ", current_r, " is missing: ", environment$lockfile,
    "\nMake sure R is running from the repository root."
  )
}

message(
  "Detected R ", getRversion(), ". Using Bioconductor ",
  environment$bioconductor, " packages from ", environment$lockfile, "."
)
message("Restoring packages. This can take some time...")
renv::consent(provided = TRUE)
renv::restore(lockfile = environment$lockfile, prompt = FALSE)
message("Package restore complete. Run source('scripts/check_setup.R') next.")
