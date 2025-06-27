# global.R - loads packages and data for the Shiny app
# This file is automatically sourced before ui.R and server.R

# Load required packages
suppressPackageStartupMessages({
  library(shiny)
  library(shinydashboard)
  library(DT)
  library(plotly)
  library(fastcpd)
})

# Set global options
options(shiny.maxRequestSize = 30*1024^2)  # 30MB max file upload