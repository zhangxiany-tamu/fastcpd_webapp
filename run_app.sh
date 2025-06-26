#!/bin/bash

# Change Point Detection Web App Launcher
echo "Starting fastcpd Web Application..."
echo "=================================="

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo "Error: R is not installed or not in PATH"
    exit 1
fi

# Navigate to app directory
cd "$(dirname "$0")"

# Check if required packages are installed
echo "Checking R package dependencies..."
Rscript -e "
required_packages <- c('shiny', 'shinydashboard', 'DT', 'plotly', 'fastcpd')
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,'Package'])]
if(length(missing_packages) > 0) {
  cat('Missing packages:', paste(missing_packages, collapse=', '), '\n')
  cat('Installing missing packages...\n')
  install.packages(missing_packages, repos='https://cran.r-project.org')
}
cat('All dependencies satisfied!\n')
"

# Launch the application
echo ""
echo "Launching web application..."
echo "The app will open in your default browser"
echo "Press Ctrl+C to stop the application"
echo ""

# Run the app with custom host and port
Rscript -e "
options(shiny.launch.browser = TRUE)
shiny::runApp(host='127.0.0.1', port=3838)
"