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
- **Change Points**: Around observations 16 and 31
- **Use Case**: Structural breaks in regression

## 🚀 How to Use

1. **Start the web application**
2. **Go to "Data Upload" tab**
3. **Select one of these sample files**
4. **Choose appropriate detection method**:
   - `mean_change.csv` → "Mean Change" method
   - `variance_change.csv` → "Variance Change" method  
   - `linear_regression.csv` → "Linear Regression" method
5. **Run analysis and examine results**

## 📈 Expected Results

Each dataset is designed with known change points to validate the detection algorithms:

- **Clear Changes**: All datasets have obvious structural breaks
- **Multiple Change Points**: Each dataset contains 2 change points
- **Different Patterns**: Three types of changes (mean, variance, regression coefficients)
- **Realistic Noise**: Appropriate noise levels for each data type

## 💡 Tips for Analysis

1. **Start with Default Parameters**: Most datasets work well with default settings
2. **Adjust Sensitivity**: If no change points detected, try lower penalty values
3. **Check Visualizations**: Always examine the plots to validate results
4. **Method Matching**: Use the appropriate method for each dataset type
5. **Parameter Tuning**: Experiment with trimming and segment count parameters

## 🔧 Generating Custom Data

You can create your own datasets following these patterns:
- **Time Series**: Single column with temporal dependencies
- **Regression**: First column as response, remaining as predictors
- **Clear Structure**: Include obvious change points for validation
- **Appropriate Size**: 40-50 observations work well for demos

## 📋 Data Format Requirements

- **CSV format** with headers
- **Numeric data** only
- **No missing values**
- **Reasonable sample sizes** (30+ observations per segment)

These sample datasets provide a testing ground for the core change point detection methods available in the fastcpd web application!