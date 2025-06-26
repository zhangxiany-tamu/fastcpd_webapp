# 📁 fastcpd Web Application - Project Structure

## 🗂️ **Clean Project Organization**

### **📱 Core Application Files**
```
webapp/
├── app.R                    # Main application launcher
├── ui.R                     # User interface definition
├── server.R                 # Server-side logic and functionality
└── run_app.sh              # Convenient startup script
```

### **📊 Sample Data**
```
sample_data/
├── README.md                # Documentation for sample datasets
├── mean_change.csv          # Mean change detection example
├── variance_change.csv      # Variance change detection example  
├── linear_regression.csv    # Linear regression example
├── logistic_regression.csv  # Logistic regression example
├── poisson_regression.csv   # Poisson regression example
├── ar_timeseries.csv        # AR time series example
├── multivariate_var.csv     # VAR multivariate example
└── garch_volatility.csv     # GARCH volatility example
```

### **📚 Documentation**
```
├── README.md                # Main application documentation
├── IMPROVEMENTS.md          # Summary of enhancements made
└── PROJECT_STRUCTURE.md     # This file - project organization
```

## 🧹 **Files Removed During Cleanup**

### **❌ Removed Unnecessary Files:**
- `server_backup.R` - Backup copy no longer needed
- `test_ui_conditions.html` - Development test file  
- `sample_data.csv` - Redundant (replaced by sample_data/ folder)

### **✅ Files Kept in Main Project:**
The main `fastcpd/` directory contains the complete R package with:
- **Python bindings** (`python/`, `pyproject.toml`, etc.) - Part of original package
- **Bazel build system** (`bazel/`, `BUILD.bazel`, etc.) - For package compilation
- **R package structure** (`R/`, `man/`, `src/`, etc.) - Core package files
- **Documentation** (`vignettes/`, `README.md`, etc.) - Package documentation

## 🎯 **Clean Separation of Concerns**

### **🌐 Web Application (webapp/)**
- **Purpose**: User-friendly interface for change point detection
- **Dependencies**: Requires fastcpd R package to be installed
- **Target Users**: Data analysts, researchers, students
- **Technology**: Shiny dashboard with interactive visualizations

### **📦 R Package (main directory)**
- **Purpose**: Core statistical algorithms and functions
- **Dependencies**: C++, Fortran, and system libraries
- **Target Users**: R developers, statisticians, programmers
- **Technology**: R package with C++ backend

## 🚀 **Quick Start**

### **Run Web Application:**
```bash
cd webapp/
./run_app.sh
```

### **Use R Package Directly:**
```r
library(fastcpd)
result <- fastcpd_mean(data)
plot(result)
```

## 📈 **Application Features**

- **📊 Interactive Dashboard**: Professional Shiny interface
- **🎯 Method Selection**: 11+ detection methods available
- **📁 Data Upload**: CSV file support with parsing options
- **📈 Rich Visualizations**: Interactive plots with Plotly
- **📋 Comprehensive Results**: Executive summaries + detailed output
- **💡 Sample Data**: 8 example datasets included
- **📱 Responsive Design**: Works on desktop and mobile
- **🎨 Professional UI**: Clean, modern interface

## 🔧 **Technical Stack**

- **Backend**: R with fastcpd package
- **Frontend**: Shiny with shinydashboard
- **Visualizations**: Plotly for interactive charts
- **Tables**: DT for data display
- **Deployment**: Standalone Shiny server

This clean, well-organized structure makes the project easy to understand, maintain, and deploy!