library(shiny)
library(shinydashboard)
library(DT)
library(plotly)
library(fastcpd)

server <- function(input, output, session) {
  
  # Reactive values to store data and results
  values <- reactiveValues(
    data = NULL,
    result = NULL,
    analysis_running = FALSE
  )
  
  # File upload and data processing
  observe({
    req(input$file)
    
    tryCatch({
      values$data <- read.csv(
        input$file$datapath,
        header = input$header,
        sep = input$sep,
        quote = input$quote,
        stringsAsFactors = input$stringsAsFactors
      )
    }, error = function(e) {
      showNotification(
        paste("📁 Error reading file:", e$message), 
        duration = 8, 
        closeButton = TRUE,
        type = "error"
      )
    })
  })
  
  # Data preview
  output$dataPreview <- DT::renderDataTable({
    if (!is.null(values$data)) {
      DT::datatable(values$data, options = list(scrollX = TRUE, pageLength = 10))
    }
  })
  
  # Enhanced data summary with statistics
  output$dataSummary <- renderPrint({
    if (!is.null(values$data)) {
      cat("📊 DATASET INFORMATION\n")
      cat("======================\n")
      cat("📏 Dimensions:", nrow(values$data), "rows ×", ncol(values$data), "columns\n")
      cat("📋 Variables:", paste(names(values$data), collapse = ", "), "\n\n")
      
      cat("📈 SUMMARY STATISTICS\n")
      cat("=====================\n")
      
      # Enhanced summary for each column
      for (i in 1:ncol(values$data)) {
        col_name <- names(values$data)[i]
        col_data <- values$data[, i]
        
        if (is.numeric(col_data)) {
          cat("\n🔢", col_name, "(numeric):\n")
          cat("   Min:", sprintf("%.3f", min(col_data, na.rm = TRUE)), "\n")
          cat("   Max:", sprintf("%.3f", max(col_data, na.rm = TRUE)), "\n")
          cat("   Mean:", sprintf("%.3f", mean(col_data, na.rm = TRUE)), "\n")
          cat("   Std Dev:", sprintf("%.3f", sd(col_data, na.rm = TRUE)), "\n")
          cat("   Missing:", sum(is.na(col_data)), "values\n")
        } else {
          cat("\n📝", col_name, "(non-numeric):\n")
          cat("   Unique values:", length(unique(col_data)), "\n")
          cat("   Missing:", sum(is.na(col_data)), "values\n")
        }
      }
      
      cat("\n📋 DATA QUALITY\n")
      cat("===============\n")
      total_missing <- sum(is.na(values$data))
      total_cells <- nrow(values$data) * ncol(values$data)
      cat("Missing values:", total_missing, "out of", total_cells, 
          sprintf("(%.1f%%)\n", 100 * total_missing / total_cells))
      
      if (ncol(values$data) == 1) {
        cat("Data type: Univariate time series\n")
      } else if (all(sapply(values$data, is.numeric))) {
        cat("Data type: Multivariate numeric\n")
      } else {
        cat("Data type: Mixed variables\n")
      }
    }
  })
  
  # Data summary visualization
  output$dataSummaryPlot <- renderPlotly({
    if (!is.null(values$data)) {
      # Create different visualizations based on data structure
      if (ncol(values$data) == 1) {
        # Univariate: histogram
        p <- plot_ly(
          x = values$data[, 1],
          type = "histogram",
          nbinsx = 30,
          name = "Distribution"
        )
        p <- layout(p,
          title = list(text = "Data Distribution", font = list(size = 14)),
          xaxis = list(title = names(values$data)[1]),
          yaxis = list(title = "Frequency"),
          showlegend = FALSE
        )
      } else if (ncol(values$data) <= 4) {
        # Few variables: correlation heatmap
        numeric_data <- values$data[sapply(values$data, is.numeric)]
        if (ncol(numeric_data) > 1) {
          cor_matrix <- cor(numeric_data, use = "complete.obs")
          p <- plot_ly(
            z = cor_matrix,
            type = "heatmap",
            colorscale = "RdBu"
          )
          p <- layout(p,
            title = list(text = "Correlation Matrix", font = list(size = 14))
          )
        } else {
          p <- plot_ly() 
          p <- add_annotations(p,
            text = "Single variable\nNo correlation plot",
            x = 0.5, y = 0.5,
            showarrow = FALSE
          )
        }
      } else {
        # Many variables: means plot
        numeric_cols <- sapply(values$data, is.numeric)
        if (sum(numeric_cols) > 0) {
          means <- sapply(values$data[numeric_cols], mean, na.rm = TRUE)
          
          p <- plot_ly(
            x = names(means),
            y = means,
            type = "scatter",
            mode = "markers",
            name = "Means"
          )
          p <- layout(p,
            title = list(text = "Variable Means", font = list(size = 14)),
            xaxis = list(title = "Variables"),
            yaxis = list(title = "Mean Value")
          )
        } else {
          p <- plot_ly()
          p <- add_annotations(p,
            text = "Non-numeric data\nNo plot available",
            x = 0.5, y = 0.5,
            showarrow = FALSE
          )
        }
      }
      p
    }
  })
  
  # Analysis status
  output$analysisStatus <- renderUI({
    if (values$analysis_running) {
      div(
        icon("spinner", class = "fa-spin"),
        "Analysis in progress... Please wait."
      )
    } else if (!is.null(values$result)) {
      # Hide status after completion - results are shown in the Results tab
      div(style = "color: #28a745;",
        icon("check-circle"),
        "Ready to view results"
      )
    }
  })
  
  # Run analysis
  observeEvent(input$runAnalysis, {
    req(values$data)
    
    values$analysis_running <- TRUE
    values$result <- NULL
    
    tryCatch({
      # Get beta parameter
      beta_param <- if (input$beta == "custom") {
        input$beta_value
      } else {
        input$beta
      }
      
      # Get order parameter for time series models
      order_param <- switch(input$family,
        "ar" = input$ar_order,
        "arma" = c(input$arma_p, input$arma_q),
        "arima" = c(input$arima_p, input$arima_d, input$arima_q),
        "garch" = c(input$garch_p, input$garch_q),
        "var" = input$var_order,
        c(0, 0, 0)
      )
      
      # Run appropriate fastcpd function
      result <- switch(input$family,
        "mean" = fastcpd_mean(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "variance" = fastcpd_variance(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "meanvariance" = fastcpd_meanvariance(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "lm" = fastcpd_lm(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "binomial" = fastcpd_binomial(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "poisson" = fastcpd_poisson(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "lasso" = fastcpd_lasso(
          data = values$data,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "ar" = fastcpd_ar(
          data = values$data,
          order = order_param,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "arma" = fastcpd_arma(
          data = values$data,
          order = order_param,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "arima" = fastcpd_arima(
          data = values$data,
          order = order_param,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only,
          include.mean = input$include_mean
        ),
        "garch" = fastcpd_garch(
          data = values$data,
          order = order_param,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        ),
        "var" = fastcpd_var(
          data = values$data,
          order = order_param,
          beta = beta_param,
          trim = input$trim,
          segment_count = input$segment_count,
          cp_only = input$cp_only
        )
      )
      
      values$result <- result
      showNotification(
        "✅ Analysis completed successfully!", 
        duration = 5, 
        closeButton = TRUE,
        type = "message"
      )
      
    }, error = function(e) {
      showNotification(
        paste("❌ Analysis failed:", e$message), 
        duration = 10, 
        closeButton = TRUE,
        type = "error"
      )
    }, finally = {
      values$analysis_running <- FALSE
    })
  })
  
  # Enhanced results summary
  output$resultsSummary <- renderUI({
    if (!is.null(values$result)) {
      cp_count <- length(values$result@cp_set)
      data_length <- nrow(values$data)
      
      # Create summary cards
      tagList(
        fluidRow(
          column(3,
            div(class = "info-box bg-blue", style = "margin: 0;",
              div(class = "info-box-icon", icon("search")),
              div(class = "info-box-content",
                span(class = "info-box-text", "Method"),
                span(class = "info-box-number", toupper(values$result@family))
              )
            )
          ),
          column(3,
            div(class = "info-box bg-green", style = "margin: 0;",
              div(class = "info-box-icon", icon("map-marker")),
              div(class = "info-box-content",
                span(class = "info-box-text", "Change Points"),
                span(class = "info-box-number", cp_count)
              )
            )
          ),
          column(3,
            div(class = "info-box bg-orange", style = "margin: 0;",
              div(class = "info-box-icon", icon("database")),
              div(class = "info-box-content",
                span(class = "info-box-text", "Data Points"),
                span(class = "info-box-number", data_length)
              )
            )
          ),
          column(3,
            div(class = "info-box bg-purple", style = "margin: 0;",
              div(class = "info-box-icon", icon("pie-chart")),
              div(class = "info-box-content",
                span(class = "info-box-text", "Segments"),
                span(class = "info-box-number", cp_count + 1)
              )
            )
          )
        ),
        
        # Analysis completion message
        if (cp_count > 0) {
          div(class = "alert alert-success", style = "margin-top: 15px;",
            h5(icon("check-circle"), " Analysis Complete"),
            p(paste0("Successfully detected ", cp_count, " change point", 
                     if(cp_count > 1) "s" else "", " in your data. ",
                     "See detailed results in the tables and visualizations below."))
          )
        } else {
          div(class = "alert alert-warning", style = "margin-top: 15px;",
            h5(icon("info-circle"), " No Change Points Detected"),
            p("The analysis did not detect any significant change points in your data."),
            p("This could mean:"),
            tags$ul(
              tags$li("The data is stationary/homogeneous"),
              tags$li("Change points are too subtle for current sensitivity"),
              tags$li("Try adjusting penalty parameters for higher sensitivity")
            )
          )
        }
      )
    } else {
      div(class = "alert alert-info",
        h4(icon("info-circle"), " No Analysis Results"),
        p("Please run the change point analysis first to see results here.")
      )
    }
  })
  
  # Detailed results (collapsible)
  output$detailedResults <- renderPrint({
    if (!is.null(values$result)) {
      cat("🔍 TECHNICAL DETAILS\n")
      cat("===================\n\n")
      
      # Show technical information without duplicating summary
      cat("📋 Object Class:", class(values$result)[1], "\n")
      cat("📊 Family:", values$result@family, "\n")
      cat("📏 Data Dimensions:", nrow(values$data), "×", ncol(values$data), "\n")
      
      if (length(values$result@cp_set) > 0) {
        cat("📍 Raw Change Points:", paste(values$result@cp_set, collapse = ", "), "\n")
      } else {
        cat("📍 Raw Change Points: None detected\n")
      }
      
      if (length(values$result@cost_values) > 0) {
        cat("💰 Cost Values (first 5):", paste(head(values$result@cost_values, 5), collapse = ", "), 
            if(length(values$result@cost_values) > 5) "..." else "", "\n")
      }
      
      if (ncol(values$result@thetas) > 0) {
        cat("🔢 Parameter Matrix:", ncol(values$result@thetas), "segments ×", nrow(values$result@thetas), "parameters\n")
      }
      
      if (length(values$result@residuals) > 0) {
        cat("📈 Residuals:", length(values$result@residuals), "values (range:", 
            sprintf("%.3f", min(values$result@residuals, na.rm = TRUE)), "to", 
            sprintf("%.3f", max(values$result@residuals, na.rm = TRUE)), ")\n")
      }
      
      cat("\n📞 Original Function Call:\n")
      cat("========================\n")
      print(values$result@call)
      
      cat("\n💡 Note: Detailed summary is shown in the Analysis Summary section above.")
      
    } else {
      cat("No technical details available.")
    }
  })
  
  # Enhanced change points table
  output$changePointsTable <- DT::renderDataTable({
    if (!is.null(values$result) && length(values$result@cp_set) > 0) {
      data_length <- nrow(values$data)
      cp_locations <- values$result@cp_set
      
      cp_data <- data.frame(
        "CP #" = 1:length(cp_locations),
        "Position" = cp_locations,
        "Percentage" = paste0(round(100 * cp_locations / data_length, 1), "%"),
        stringsAsFactors = FALSE
      )
      
      DT::datatable(
        cp_data, 
        options = list(
          pageLength = 10,
          scrollX = TRUE
        ),
        rownames = FALSE
      )
    } else {
      # Empty table with message
      empty_data <- data.frame(
        "Message" = "No change points detected",
        stringsAsFactors = FALSE
      )
      DT::datatable(
        empty_data,
        options = list(dom = 't', ordering = FALSE),
        rownames = FALSE
      )
    }
  })
  
  # Parameters table
  output$parametersTable <- DT::renderDataTable({
    if (!is.null(values$result) && ncol(values$result@thetas) > 0) {
      # Create a clean parameters table without meaningless row numbers
      params_data <- as.data.frame(values$result@thetas)
      
      # Add meaningful row names as Parameter column if parameters have names
      if (!is.null(rownames(values$result@thetas)) && 
          !all(rownames(values$result@thetas) == as.character(1:nrow(values$result@thetas)))) {
        params_data <- data.frame(
          Parameter = rownames(values$result@thetas),
          params_data,
          stringsAsFactors = FALSE
        )
      }
      
      DT::datatable(
        params_data, 
        options = list(
          pageLength = 10, 
          scrollX = TRUE,
          columnDefs = list(
            list(className = 'dt-center', targets = '_all')
          )
        ),
        rownames = FALSE
      ) %>%
      DT::formatRound(columns = 1:ncol(params_data), digits = 4)
    } else {
      # Empty table with message when no parameters available
      empty_data <- data.frame(
        "Message" = "No model parameters available (try unchecking 'Change Points Only')",
        stringsAsFactors = FALSE
      )
      DT::datatable(
        empty_data,
        options = list(dom = 't', ordering = FALSE),
        rownames = FALSE
      )
    }
  })
  
  # Data plot
  output$dataPlot <- renderPlotly({
    if (!is.null(values$data)) {
      # Create plot based on data structure
      if (ncol(values$data) == 1) {
        # Univariate time series
        p <- plot_ly(
          x = 1:nrow(values$data),
          y = values$data[, 1],
          type = "scatter",
          mode = "lines",
          name = "Data"
        )
        p <- layout(p,
          title = "Time Series Data",
          xaxis = list(title = "Time"),
          yaxis = list(title = "Value")
        )
      } else {
        # Multivariate data - plot first column
        p <- plot_ly(
          x = 1:nrow(values$data),
          y = values$data[, 1],
          type = "scatter",
          mode = "lines+markers",
          name = names(values$data)[1]
        )
        p <- layout(p,
          title = "Data Overview (First Column)",
          xaxis = list(title = "Index"),
          yaxis = list(title = "Value")
        )
      }
      p
    }
  })
  
  # Change points plot
  output$changePointsPlot <- renderPlotly({
    if (!is.null(values$result) && !is.null(values$data)) {
      # Plot data with change points
      if (ncol(values$data) == 1) {
        p <- plot_ly(
          x = 1:nrow(values$data),
          y = values$data[, 1],
          type = "scatter",
          mode = "lines",
          name = "Data",
          line = list(color = "blue")
        )
        
        # Add change points as vertical lines
        if (length(values$result@cp_set) > 0) {
          for (cp in values$result@cp_set) {
            p <- add_trace(p,
              x = c(cp, cp),
              y = c(min(values$data[, 1]), max(values$data[, 1])),
              type = "scatter",
              mode = "lines",
              name = paste("CP", cp),
              line = list(color = "red", dash = "dash"),
              showlegend = FALSE
            )
          }
        }
        
        p <- layout(p,
          title = "Data with Change Points",
          xaxis = list(title = "Time"),
          yaxis = list(title = "Value")
        )
      } else {
        # Multivariate case - plot first column with change points
        p <- plot_ly(
          x = 1:nrow(values$data),
          y = values$data[, 1],
          type = "scatter",
          mode = "lines+markers",
          name = names(values$data)[1]
        )
        
        # Add change points
        if (length(values$result@cp_set) > 0) {
          for (cp in values$result@cp_set) {
            p <- add_trace(p,
              x = c(cp, cp),
              y = c(min(values$data[, 1]), max(values$data[, 1])),
              type = "scatter",
              mode = "lines",
              name = paste("CP", cp),
              line = list(color = "red", dash = "dash"),
              showlegend = FALSE
            )
          }
        }
        
        p <- layout(p,
          title = "Data with Change Points",
          xaxis = list(title = "Index"),
          yaxis = list(title = "Value")
        )
      }
      p
    }
  })
  
  # Residuals plot
  output$residualsPlot <- renderPlotly({
    if (!is.null(values$result) && length(values$result@residuals) > 0) {
      p <- plot_ly(
        x = 1:length(values$result@residuals),
        y = values$result@residuals,
        type = "scatter",
        mode = "lines+markers",
        name = "Residuals"
      )
      p <- layout(p,
        title = "Model Residuals",
        xaxis = list(title = "Index"),
        yaxis = list(title = "Residual")
      )
      p
    }
  })
  
  # Show residuals plot conditionally
  output$showResiduals <- reactive({
    !is.null(values$result) && length(values$result@residuals) > 0
  })
  outputOptions(output, "showResiduals", suspendWhenHidden = FALSE)
}