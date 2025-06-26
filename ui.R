library(shiny)
library(shinydashboard)
library(DT)
library(plotly)

ui <- dashboardPage(
  dashboardHeader(title = "fastcpd"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Data Upload", tabName = "upload", icon = icon("upload")),
      menuItem("Analysis", tabName = "analysis", icon = icon("chart-line")),
      menuItem("Results", tabName = "results", icon = icon("table")),
      menuItem("Visualization", tabName = "plots", icon = icon("chart-area")),
      menuItem("Help", tabName = "help", icon = icon("question-circle"))
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$style(HTML("
        .content-wrapper, .right-side {
          background-color: #f4f4f4;
        }
        .box {
          border-radius: 5px;
        }
        .main-header .navbar {
          background-color: #3c8dbc !important;
        }
      "))
    ),
    
    tabItems(
      # Data Upload Tab
      tabItem(tabName = "upload",
        fluidRow(
          box(
            title = "Data Upload", status = "primary", solidHeader = TRUE, width = 12,
            fileInput("file", "Choose CSV File",
                     accept = c(".csv", ".txt"),
                     buttonLabel = "Browse...",
                     placeholder = "No file selected"),
            checkboxInput("header", "Header", TRUE),
            checkboxInput("stringsAsFactors", "Strings as factors", FALSE),
            radioButtons("sep", "Separator",
                        choices = c(Comma = ',', Semicolon = ';', Tab = '\t'),
                        selected = ','),
            radioButtons("quote", "Quote",
                        choices = c(None = '', "Double Quote" = '"', "Single Quote" = "'"),
                        selected = '"')
          )
        ),
        fluidRow(
          box(
            title = "Data Preview", status = "info", solidHeader = TRUE, width = 12,
            DT::dataTableOutput("dataPreview")
          )
        ),
        fluidRow(
          box(
            title = "Data Summary", status = "success", solidHeader = TRUE, width = 8,
            verbatimTextOutput("dataSummary")
          ),
          box(
            title = "Data Visualization", status = "info", solidHeader = TRUE, width = 4,
            plotlyOutput("dataSummaryPlot", height = "300px")
          )
        )
      ),
      
      # Analysis Tab
      tabItem(tabName = "analysis",
        fluidRow(
          box(
            title = "Model Configuration", status = "primary", solidHeader = TRUE, width = 6,
            selectInput("family", "Choose Detection Method:",
              choices = list(
                "Basic Statistics" = list(
                  "Mean Change" = "mean",
                  "Variance Change" = "variance", 
                  "Mean & Variance Change" = "meanvariance"
                ),
                "Regression Models" = list(
                  "Linear Regression" = "lm",
                  "Logistic Regression" = "binomial",
                  "Poisson Regression" = "poisson",
                  "Lasso Regression" = "lasso"
                ),
                "Time Series Models" = list(
                  "AR(p) Model" = "ar",
                  "ARMA(p,q) Model" = "arma", 
                  "ARIMA(p,d,q) Model" = "arima",
                  "GARCH(p,q) Model" = "garch",
                  "VAR(p) Model" = "var"
                )
              ),
              selected = "mean"
            ),
            
            # Method-specific parameters
            conditionalPanel(
              condition = "input.family == 'ar'",
              h4("AR Model Parameters", style = "color: #3c8dbc; margin-top: 15px;"),
              div(class = "well", style = "background-color: #f9f9f9;",
                numericInput("ar_order", "AR Order (p):", value = 1, min = 1, max = 10),
                helpText("Order of the autoregressive model. Higher values capture more complex dependencies.")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'arma'",
              h4("ARMA Model Parameters", style = "color: #3c8dbc; margin-top: 15px;"),
              div(class = "well", style = "background-color: #f9f9f9;",
                fluidRow(
                  column(6, numericInput("arma_p", "AR Order (p):", value = 1, min = 0, max = 5)),
                  column(6, numericInput("arma_q", "MA Order (q):", value = 1, min = 0, max = 5))
                ),
                helpText("p: autoregressive terms, q: moving average terms")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'arima'",
              h4("ARIMA Model Parameters", style = "color: #3c8dbc; margin-top: 15px;"),
              div(class = "well", style = "background-color: #f9f9f9;",
                fluidRow(
                  column(4, numericInput("arima_p", "AR Order (p):", value = 1, min = 0, max = 5)),
                  column(4, numericInput("arima_d", "Differencing (d):", value = 1, min = 0, max = 2)),
                  column(4, numericInput("arima_q", "MA Order (q):", value = 1, min = 0, max = 5))
                ),
                checkboxInput("include_mean", "Include Mean Term", TRUE),
                helpText("p: AR terms, d: differencing order, q: MA terms")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'garch'",
              h4("GARCH Model Parameters", style = "color: #3c8dbc; margin-top: 15px;"),
              div(class = "well", style = "background-color: #f9f9f9;",
                fluidRow(
                  column(6, numericInput("garch_p", "GARCH Order (p):", value = 1, min = 1, max = 5)),
                  column(6, numericInput("garch_q", "ARCH Order (q):", value = 1, min = 1, max = 5))
                ),
                helpText("p: GARCH terms, q: ARCH terms for volatility modeling")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'var'",
              h4("VAR Model Parameters", style = "color: #3c8dbc; margin-top: 15px;"),
              div(class = "well", style = "background-color: #f9f9f9;",
                numericInput("var_order", "VAR Order (p):", value = 1, min = 1, max = 5),
                helpText("Number of lags in the Vector Autoregressive model")
              )
            ),
            
            # Data format guidance - method specific
            conditionalPanel(
              condition = "input.family == 'mean' || input.family == 'variance' || input.family == 'meanvariance'",
              div(class = "alert alert-info", style = "margin-top: 15px;",
                h5(icon("info-circle"), " Data Format Required:"),
                tags$ul(
                  tags$li("Single column: univariate analysis"),
                  tags$li("Multiple columns: multivariate analysis"),
                  tags$li("Each row represents one observation")
                ),
                tags$small("Example: mean_change.csv from sample data")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'lm' || input.family == 'binomial' || input.family == 'poisson' || input.family == 'lasso'",
              div(class = "alert alert-info", style = "margin-top: 15px;",
                h5(icon("info-circle"), " Data Format Required:"),
                tags$ul(
                  tags$li(tags$b("First column:"), " response variable (y)"),
                  tags$li(tags$b("Other columns:"), " predictor variables (x1, x2, ...)"),
                  tags$li("Each row represents one observation")
                ),
                tags$small("Example: linear_regression.csv from sample data")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'ar' || input.family == 'arma' || input.family == 'arima' || input.family == 'garch'",
              div(class = "alert alert-info", style = "margin-top: 15px;",
                h5(icon("info-circle"), " Data Format Required:"),
                tags$ul(
                  tags$li(tags$b("Single column:"), " time series values"),
                  tags$li("Sequential observations in chronological order"),
                  tags$li("No missing values recommended")
                ),
                tags$small("Example: ar_timeseries.csv from sample data")
              )
            ),
            
            conditionalPanel(
              condition = "input.family == 'var'",
              div(class = "alert alert-info", style = "margin-top: 15px;",
                h5(icon("info-circle"), " Data Format Required:"),
                tags$ul(
                  tags$li(tags$b("Multiple columns:"), " multivariate time series"),
                  tags$li("Each column represents one variable"),
                  tags$li("Sequential observations in chronological order")
                ),
                tags$small("Example: multivariate_var.csv from sample data")
              )
            )
          ),
          
          box(
            title = "Detection Parameters", status = "warning", solidHeader = TRUE, width = 6,
            
            # Penalty criterion section
            h5("Penalty Criterion", style = "margin-bottom: 10px;"),
            selectInput("beta", NULL,
              choices = list(
                "MBIC (Recommended)" = "MBIC", 
                "BIC" = "BIC", 
                "MDL" = "MDL", 
                "Custom Value" = "custom"
              ),
              selected = "MBIC"
            ),
            conditionalPanel(
              condition = "input.beta == 'custom'",
              numericInput("beta_value", "Custom Beta Value:", value = 10, min = 0, step = 0.1)
            ),
            helpText("Higher values = fewer change points detected"),
            
            hr(),
            
            # Algorithm parameters
            h5("Algorithm Parameters", style = "margin-bottom: 10px;"),
            
            fluidRow(
              column(6,
                numericInput("trim", "Trimming:", 
                           value = 0.05, min = 0, max = 0.5, step = 0.01),
                helpText("Minimum segment proportion")
              ),
              column(6,
                numericInput("segment_count", "Initial Segments:", 
                           value = 10, min = 1, max = 100),
                helpText("Starting estimate")
              )
            ),
            
            hr(),
            
            # Output options
            h5("Output Options", style = "margin-bottom: 10px;"),
            checkboxInput("cp_only", "Change Points Only", FALSE),
            helpText("Uncheck to get detailed parameters and residuals")
          )
        ),
        
        fluidRow(
          box(
            title = "Run Analysis", status = "success", solidHeader = TRUE, width = 12,
            div(style = "text-align: center;",
                actionButton("runAnalysis", "Run Change Point Detection", 
                           class = "btn-primary btn-lg", icon = icon("play")),
                br(), br(),
                uiOutput("analysisStatus")
            )
          )
        )
      ),
      
      # Results Tab
      tabItem(tabName = "results",
        fluidRow(
          box(
            title = "Analysis Summary", status = "primary", solidHeader = TRUE, width = 12,
            uiOutput("resultsSummary")
          )
        ),
        fluidRow(
          box(
            title = "Technical Details", status = "info", solidHeader = TRUE, width = 12,
            collapsible = TRUE, collapsed = TRUE,
            verbatimTextOutput("detailedResults")
          )
        ),
        fluidRow(
          box(
            title = "Change Points Summary", status = "info", solidHeader = TRUE, width = 6,
            DT::dataTableOutput("changePointsTable")
          ),
          box(
            title = "Model Parameters", status = "success", solidHeader = TRUE, width = 6,
            DT::dataTableOutput("parametersTable")
          )
        )
      ),
      
      # Visualization Tab
      tabItem(tabName = "plots",
        fluidRow(
          box(
            title = "Data Visualization", status = "primary", solidHeader = TRUE, width = 12,
            plotlyOutput("dataPlot", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Change Points Plot", status = "info", solidHeader = TRUE, width = 12,
            plotlyOutput("changePointsPlot", height = "400px")
          )
        ),
        conditionalPanel(
          condition = "output.showResiduals",
          fluidRow(
            box(
              title = "Residuals Plot", status = "success", solidHeader = TRUE, width = 12,
              plotlyOutput("residualsPlot", height = "300px")
            )
          )
        )
      ),
      
      # Help Tab
      tabItem(tabName = "help",
        fluidRow(
          box(
            title = "Quick Start Guide", status = "primary", solidHeader = TRUE, width = 6,
            h4("📋 Step-by-Step"),
            tags$ol(
              tags$li(tags$b("Upload Data:"), "CSV file in the 'Data Upload' tab"),
              tags$li(tags$b("Choose Method:"), "Select detection method in 'Analysis' tab"),
              tags$li(tags$b("Configure:"), "Set method-specific parameters (if any)"),
              tags$li(tags$b("Run Analysis:"), "Click the blue 'Run' button"),
              tags$li(tags$b("View Results:"), "Check 'Results' and 'Visualization' tabs")
            ),
            
            h4("🎯 Sample Data"),
            p("Try the sample datasets in the", code("sample_data/"), "folder:"),
            tags$ul(
              tags$li(code("mean_change.csv"), "→ Mean Change"),
              tags$li(code("linear_regression.csv"), "→ Linear Regression"),
              tags$li(code("ar_timeseries.csv"), "→ AR(1) Model")
            )
          ),
          
          box(
            title = "Detection Methods", status = "info", solidHeader = TRUE, width = 6,
            
            h5("📊 Basic Statistics"),
            tags$ul(
              tags$li(tags$b("Mean Change:"), "Shifts in average values"),
              tags$li(tags$b("Variance Change:"), "Changes in data variability"),
              tags$li(tags$b("Mean & Variance:"), "Both types simultaneously")
            ),
            
            h5("📈 Regression Models"),
            tags$ul(
              tags$li(tags$b("Linear:"), "Changes in linear relationships"),
              tags$li(tags$b("Logistic:"), "Binary outcome changes"),
              tags$li(tags$b("Poisson:"), "Count data rate changes"),
              tags$li(tags$b("Lasso:"), "Penalized regression with selection")
            ),
            
            h5("⏱️ Time Series Models"),
            tags$ul(
              tags$li(tags$b("AR(p):"), "Autoregressive dependencies"),
              tags$li(tags$b("ARMA(p,q):"), "Combined AR + MA terms"),
              tags$li(tags$b("ARIMA(p,d,q):"), "Integrated ARMA"),
              tags$li(tags$b("GARCH(p,q):"), "Volatility clustering"),
              tags$li(tags$b("VAR(p):"), "Multivariate time series")
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Data Format Requirements", status = "warning", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(4,
                h5("📈 Basic Statistics"),
                div(class = "well",
                  tags$ul(
                    tags$li("Single or multiple columns"),
                    tags$li("Each row = observation"),
                    tags$li("Numeric values only")
                  )
                ),
                tags$b("Example:"), br(),
                code("value"), br(),
                code("1.2"), br(),
                code("1.1"), br(),
                code("..."), br()
              ),
              
              column(4,
                h5("📊 Regression Data"),
                div(class = "well",
                  tags$ul(
                    tags$li("First column: response (y)"),
                    tags$li("Other columns: predictors (x1, x2, ...)"),
                    tags$li("Binary outcomes for logistic")
                  )
                ),
                tags$b("Example:"), br(),
                code("y,x1,x2"), br(),
                code("1.2,0.5,0.8"), br(),
                code("2.1,1.0,1.2"), br(),
                code("..."), br()
              ),
              
              column(4,
                h5("⏱️ Time Series"),
                div(class = "well",
                  tags$ul(
                    tags$li("Single column for univariate"),
                    tags$li("Multiple columns for VAR"),
                    tags$li("Sequential observations")
                  )
                ),
                tags$b("Example:"), br(),
                code("value"), br(),
                code("0.12"), br(),
                code("-0.15"), br(),
                code("..."), br()
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Parameter Guidelines", status = "success", solidHeader = TRUE, width = 12,
            
            fluidRow(
              column(6,
                h5("🎯 Penalty Criteria"),
                tags$ul(
                  tags$li(tags$b("MBIC (Recommended):"), "Balanced detection"),
                  tags$li(tags$b("BIC:"), "Conservative, fewer change points"),
                  tags$li(tags$b("MDL:"), "Information-theoretic approach"),
                  tags$li(tags$b("Custom:"), "Manual control (higher = fewer CPs)")
                )
              ),
              column(6,
                h5("⚙️ Algorithm Settings"),
                tags$ul(
                  tags$li(tags$b("Trimming:"), "Minimum segment size (0.05 = 5%)"),
                  tags$li(tags$b("Initial Segments:"), "Starting guess (usually 10)"),
                  tags$li(tags$b("CP Only:"), "Uncheck for detailed results")
                )
              )
            )
          )
        )
      )
    )
  )
)