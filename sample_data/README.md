# Sample Datasets for Change Point Detection

This directory contains sample datasets to demonstrate different change point detection methods in the fastcpd web application.

## 📊 Dataset Descriptions

### 1. **mean_change.csv**
- **Type**: Univariate time series
- **Method**: Mean Change Detection
- **Description**: Data with 3 distinct mean levels (μ₁≈1, μ₂≈5, μ₃≈2)
- **Change Points**: Around observations 15 and 30
- **Use Case**: Basic mean shift detection

### 2. **variance_change.csv**
- **Type**: Univariate time series  
- **Method**: Variance Change Detection
- **Description**: Data with constant mean (≈2) but changing variance
- **Change Points**: Around observations 15 and 30
- **Use Case**: Volatility change detection

### 3. **linear_regression.csv**
- **Type**: Regression data (y, x1, x2)
- **Method**: Linear Regression
- **Description**: Linear relationship changes between response and predictors
- **Change Points**: Around observations 15 and 30
- **Use Case**: Structural breaks in regression

### 4. **logistic_regression.csv**
- **Type**: Binary classification data (y, x1, x2)
- **Method**: Logistic Regression
- **Description**: Binary outcome with changing predictor relationships
- **Change Points**: Around observations 15 and 30
- **Use Case**: Classification boundary changes

### 5. **poisson_regression.csv**
- **Type**: Count data (y, x1, x2)
- **Method**: Poisson Regression
- **Description**: Count outcomes with changing rate parameters
- **Change Points**: Around observations 15 and 30
- **Use Case**: Event rate changes

### 6. **ar_timeseries.csv**
- **Type**: Univariate time series
- **Method**: AR(1) Model
- **Description**: Autoregressive process with changing AR coefficient
- **Change Points**: Around observation 50
- **Use Case**: Time series parameter changes

### 7. **multivariate_var.csv**
- **Type**: Multivariate time series (y1, y2, y3)
- **Method**: VAR(1) Model
- **Description**: Vector autoregression with changing coefficients
- **Change Points**: Around observations 15 and 30
- **Use Case**: Multivariate time series analysis

### 8. **garch_volatility.csv**
- **Type**: Univariate time series
- **Method**: GARCH Model
- **Description**: Financial-like returns with changing volatility clustering
- **Change Points**: Around observations 15 and 30
- **Use Case**: Volatility modeling

## 🚀 How to Use

1. **Start the web application**
2. **Go to "Data Upload" tab**
3. **Select one of these sample files**
4. **Choose appropriate detection method**:
   - Use filename prefix to guide method selection
   - e.g., `mean_change.csv` → "Mean Change" method
5. **Run analysis and examine results**

## 📈 Expected Results

Each dataset is designed with known change points to validate the detection algorithms:

- **Clear Changes**: Most datasets have obvious structural breaks
- **Multiple Change Points**: Several datasets contain 2-3 change points
- **Different Patterns**: Various types of changes (mean, variance, coefficients)
- **Realistic Noise**: Appropriate noise levels for each data type

## 💡 Tips for Analysis

1. **Start with Default Parameters**: Most datasets work well with default settings
2. **Adjust Sensitivity**: If no change points detected, try lower penalty values
3. **Check Visualizations**: Always examine the plots to validate results
4. **Compare Methods**: Try different detection methods on the same data
5. **Parameter Tuning**: Experiment with trimming and segment count parameters

## 🔧 Generating Custom Data

You can create your own datasets following these patterns:
- **Time Series**: Single column with temporal dependencies
- **Regression**: First column as response, remaining as predictors
- **Clear Structure**: Include obvious change points for validation
- **Appropriate Size**: 50-200 observations work well for demos

## 📋 Data Format Requirements

- **CSV format** with headers
- **Numeric data** (except binary outcomes for logistic regression)
- **No missing values**
- **Reasonable sample sizes** (30+ observations per segment)

These sample datasets provide a comprehensive testing ground for all change point detection methods available in the fastcpd web application!