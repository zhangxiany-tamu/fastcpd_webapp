# .Rprofile for fastcpd web application
# This ensures packages are loaded when the app starts

# Set CRAN mirror
options(repos = c(CRAN = "https://cran.rstudio.com/"))

# Load required packages
if (!require("shiny")) install.packages("shiny")
if (!require("shinydashboard")) install.packages("shinydashboard")
if (!require("DT")) install.packages("DT")
if (!require("plotly")) install.packages("plotly")
if (!require("fastcpd")) install.packages("fastcpd")

library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(fastcpd)