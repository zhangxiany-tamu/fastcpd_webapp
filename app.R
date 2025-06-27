# fastcpd Web Application
# Load required libraries
library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(fastcpd)

# Source UI and Server components
source("ui.R")
source("server.R")

# Run the application
shinyApp(ui = ui, server = server)