# install_packages.R
# Install required packages for fastcpd web application

# Set CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# List of required packages
packages <- c("shiny", "shinydashboard", "DT", "plotly", "fastcpd")

# Install missing packages
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

cat("All required packages installed successfully!\n")