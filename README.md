# fastcpd Web Application

A Shiny web interface for the [fastcpd](https://github.com/doccstat/fastcpd) R package, providing an intuitive way to perform change point detection without programming.

## Features

- **Interactive Interface**: Upload CSV data and configure analysis through a web dashboard
- **Multiple Methods**: Support for mean, variance, regression, and time series change point detection
- **Rich Visualizations**: Interactive plots showing data and detected change points
- **Sample Data**: Includes example datasets for testing different detection methods
- **Export-Ready Results**: Detailed summaries and professional visualizations

## Quick Start

1. **Install Dependencies** (from terminal)
   ```bash
   Rscript -e "install.packages(c('shiny', 'shinydashboard', 'DT', 'plotly', 'fastcpd'))"
   ```

2. **Run the Application** (one-line start)
   ```bash
   git clone https://github.com/zhangxiany-tamu/fastcpd_webapp.git && cd fastcpd_webapp && Rscript -e "shiny::runApp(host='0.0.0.0', port=3838)"
   ```

3. **Use the Interface**
   - Upload your CSV data in the "Data Upload" tab
   - Select detection method in "Analysis" tab
   - View results and visualizations in "Results" and "Visualization" tabs

## Detection Methods

- **Basic Statistics**: Mean, variance, and mean+variance changes
- **Regression**: Linear, logistic, Poisson, and LASSO regression
- **Time Series**: AR, ARMA, ARIMA, GARCH, and VAR models

*Note: Sample data is provided for mean, variance, and linear regression methods.*

## Data Requirements

Each method has specific data format requirements:
- **Time series models**: Single column of sequential observations
- **Regression models**: First column as response, remaining as predictors
- **Basic statistics**: Single or multiple columns for univariate/multivariate analysis

See the included sample datasets for examples.

## About

This web application provides a user-friendly interface to the powerful [fastcpd](https://github.com/doccstat/fastcpd) package developed by Xingchi Li and Xianyang Zhang. The underlying algorithms are described in their paper "fastcpd: Fast Change Point Detection in R" (arXiv:2404.05933).

## License

This web interface is provided as-is. The underlying fastcpd package has its own license terms.