# Load required packages
source("global.R")

# Source UI and Server
source("ui.R")
source("server.R")

# Create and run the Shiny app
shinyApp(ui = ui, server = server)