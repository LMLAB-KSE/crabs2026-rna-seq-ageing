# Installation guide

The supported configuration is R 4.5.x on Windows 11, recent macOS, or a recent
Ubuntu/Debian release. RStudio Desktop is recommended. Package versions are
recorded in `renv.lock`.

## Windows 11

1. Install R 4.5.x from <https://cran.r-project.org/bin/windows/base/>.
2. Install RStudio Desktop from <https://posit.co/download/rstudio-desktop/>.
3. Install the matching Rtools release from
   <https://cran.r-project.org/bin/windows/Rtools/>. Accept the default options.
4. Restart RStudio after installation.

Most packages are available as Windows binaries. Rtools is needed if a package
must be compiled from source.

## macOS

1. Install R 4.5.x from <https://cran.r-project.org/bin/macosx/>. Choose the
   installer matching Apple silicon or Intel.
2. Install RStudio Desktop.
3. In Terminal, install Apple's command-line tools:

```bash
xcode-select --install
```

If package installation reports missing `gfortran`, install the matching
compiler listed on the CRAN R for macOS tools page.

## Ubuntu or Debian

Install R 4.5.x using the CRAN instructions for your distribution, then install
common compilation and graphics libraries:

```bash
sudo apt update
sudo apt install -y build-essential gfortran libcurl4-openssl-dev \
  libssl-dev libxml2-dev libfontconfig1-dev libfreetype6-dev \
  libpng-dev libtiff5-dev libjpeg-dev libharfbuzz-dev libfribidi-dev \
  libgit2-dev libglpk-dev libgsl-dev
```

Package names can differ on older releases. Use the missing library name in the
installation error to identify the corresponding development package.

## Restore the R environment

Open the project from its root and run:

```r
source("scripts/setup.R")
```

This installs `renv` if needed and restores packages from `renv.lock`. Do not
install workshop packages one by one unless troubleshooting.

Then verify the environment and download the source data:

```r
source("scripts/check_setup.R")
source("scripts/download_data.R")
source("scripts/check_setup.R")
```

## Common problems

- **The project uses the wrong R version:** install R 4.5.x, restart RStudio,
  and select it under *Tools > Global Options > General > R version*.
- **A package cannot compile:** read the first `configuration failed` or
  `library not found` message, install that system dependency, and rerun setup.
- **The ovarian download stops:** rerun `download_data.R`; a suspicious partial
  file is removed before retrying.
- **Out of memory:** close other applications. The ovarian workflow is designed
  for 16 GB RAM and avoids making an uncompressed copy of the source object.
- **No permission to install system software:** contact the instructor before
  the workshop; restoring packages cannot replace missing system libraries.
