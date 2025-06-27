# fastcpd Web Application
# Source UI and Server components
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server)