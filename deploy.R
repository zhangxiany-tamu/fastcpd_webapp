# deploy.R - Generate proper manifest and deploy to Posit Cloud

# Install rsconnect if not available
if (!require("rsconnect", quietly = TRUE)) {
  install.packages("rsconnect")
  library(rsconnect)
}

# Install required packages if not available
packages <- c("shiny", "shinydashboard", "DT", "plotly", "fastcpd")
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# Generate proper manifest.json
cat("Generating manifest.json...\n")
rsconnect::writeManifest()

cat("Manifest generated successfully!\n")
cat("You can now deploy to Posit Cloud.\n")