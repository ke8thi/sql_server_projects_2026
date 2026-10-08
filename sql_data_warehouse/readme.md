# SQL Data Warehouse Project

## 📌 Project Overview

This project is a complete SQL Server Data Warehouse project built using
raw CRM and ERP datasets.

The goal is to design and implement a modern data warehouse using a
Bronze → Silver → Gold architecture and perform data exploration and
analytics on the transformed data.

The project is being built step-by-step to practice SQL Server,
ETL processes, data cleaning, transformation, data modeling, and
analytical SQL.

---

## 🏗️ Data Warehouse Architecture

```text
CRM Source Files ──┐
                   │
                   ├──> Bronze ──> Silver ──> Gold ──> Analytics
                   │
ERP Source Files ──┘
The data warehouse follows a layered architecture:
Source Systems
      ↓
🥉 Bronze Layer
      ↓
🥈 Silver Layer
      ↓
🥇 Gold Layer
      ↓
📊 Analytics
🗄️ Source Systems
CRM
The CRM source contains:
- Customer information
- Product information
- Sales information
ERP
The ERP source contains:
- Customer information
- Location information
- Product category information
🥉 Bronze Layer
Purpose
The Bronze layer stores the source data in its raw form with minimal
transformation.
The objective is to preserve the original source data before applying
cleaning or business transformations.
Bronze Tables
Source	Bronze Table	Rows
CRM Customer	bronze.crm_cust_info	18,493
CRM Product	bronze.crm_prd_info	397
CRM Sales	bronze.crm_sales_details	60,398
ERP Customer	bronze.erp_cust_az12	18,483
ERP Location	bronze.erp_loc_a101	18,484
ERP Product Category	bronze.erp_px_cat_g1v2	37


Bronze ETL Process
The Bronze loading procedure performs a full refresh.
Source CSV
    ↓
TRUNCATE Bronze Table
    ↓
BULK INSERT
    ↓
Measure Load Duration
    ↓
Next Table

The stored procedure:
bronze.load_bronze

handles:
- Full loading of CRM tables
- Full loading of ERP tables
- Individual table load-time measurement
- Total batch-time measurement
- Error handling using try...catch
Bronze Validation
The Bronze layer was validated using:
- Row-count validation
- NULL-value checks
- Successful execution of the ETL procedure
🥈 Silver Layer
Purpose
The Silver layer contains cleaned, standardized, and transformed data
from the Bronze layer.
The objective is to prepare reliable and consistent data for the Gold
business layer.
Silver Tables
Source	Silver Table	Rows
CRM Customer	silver.crm_cust_info	18,484
CRM Product	silver.crm_prd_info	397
CRM Sales	silver.crm_sales_details	60,398
ERP Customer	silver.erp_cust_az12	18,483
ERP Location	silver.erp_loc_a101	18,484
ERP Product Category	silver.erp_px_cat_g1v2	37


Silver Transformations
CRM Customer
- Removed records with NULL customer IDs
- Removed duplicate customer versions
- Kept the latest record based on creation date
- Trimmed customer first and last names
- Standardized marital status
- Standardized gender values
CRM Product
- Extracted and standardized category IDs
- Standardized product keys
- Replaced NULL product costs with 0
- Standardized product line values
- Converted dates to DATE
- Derived product end dates using the next product start date
CRM Sales
- Standardized order, shipping, and due dates
- Converted invalid dates to NULL
- Corrected invalid or missing sales values
- Corrected invalid or missing prices
- Validated sales calculations
ERP Customer
- Removed the NAS prefix from customer IDs
- Converted future birth dates to NULL
- Standardized gender values
ERP Location
- Removed hyphens from customer IDs
- Standardized country names
- Converted DE to Germany
- Converted US / USA to United States
- Standardized missing countries to n/a
ERP Product Category
- Loaded category data into the Silver layer
- Preserved the source category structure
Silver ETL Process
Bronze Tables
     ↓
TRUNCATE Silver Tables
     ↓
Transform & Clean Data
     ↓
INSERT into Silver Tables
     ↓
Measure Load Duration
     ↓
Validate Data Quality

The stored procedure:
silver.load_silver

handles:
- Full refresh of Silver tables
- Data cleaning
- Data standardization
- Data transformation
- Individual table load-time measurement
- Total batch-time measurement
- Error handling using try...catch
Silver Validation
The Silver layer was validated using comprehensive data quality checks
covering:
- NULL values
- Duplicate records
- Leading/trailing spaces
- Invalid standardized values
- Negative product costs
- Invalid sales values
- Invalid quantities
- Invalid prices
- Sales calculation consistency
- Date consistency
- Future birth dates
- Country standardization
- Product end-date calculations
All Silver validation checks returned:
issue_count = 0

The Silver layer is therefore successfully loaded and validated.
🥇 Gold Layer
Purpose
The Gold layer will contain business-ready data designed for analytics
and reporting.
The Gold layer will transform the cleaned Silver data into a
business-oriented dimensional model.
Planned Gold Tables
gold.dim_customers
gold.dim_products
gold.fact_sales

The Gold layer will follow a Star Schema consisting of:
                 ┌─────────────────────┐
                 │   dim_customers     │
                 └──────────┬──────────┘
                            │
                            │
┌──────────────────┐   ┌────▼─────┐   ┌──────────────────┐
│  dim_products    │───│fact_sales│
└──────────────────┘   └──────────┘

Planned Gold Transformations
The Gold layer will focus on:
- Creating dimension tables
- Creating fact tables
- Establishing relationships
- Generating surrogate keys
- Integrating CRM and ERP information
- Creating business-friendly attributes
- Preparing data for analytical queries
🛠️ Technologies Used
- SQL Server
- T-SQL
- SQL Server Management Studio
- Git
- GitHub
📚 SQL Concepts Practiced
- DDL
- DML
- Filtering
- Joins
- Advanced Joins
- Anti-Joins
- Set Operators
- String Functions
- Numeric Functions
- Date & Time Functions
- NULL Functions
- CASE Statements
- Aggregate Functions
- Window Functions
- Subqueries
- CTEs
- Views
- CTAS
- Temporary Tables
- Stored Procedures
- Error Handling
- Bulk Data Loading
- Data Validation
- Data Cleaning
- Data Transformation
- Data Warehouse Architecture
- ETL
- Dimensional Modeling
- Star Schema
📁 Project Structure
sql_server_projects_2026/
│
└── sql_data_warehouse/
    │
    ├── scripts/
    │   │
    │   ├── bronze/
    │   │   ├── ddl_bronze.sql
    │   │   └── proc_load_bronze.sql
    │   │
    │   ├── silver/
    │   │   ├── ddl_silver.sql
    │   │   ├── proc_load_silver.sql
    │   │   └── quality_checks_silver.sql
    │   │
    │   └── gold/
    │       ├── ddl_gold.sql
    │       ├── proc_load_gold.sql
    │       └── quality_checks_gold.sql
    │
    ├── docs/
    │
    └── README.md

The Gold scripts and documentation will be added as the project
progresses.

🚧 Project Progress
Phase	Status
Project Setup	✅ Completed
Bronze Layer	✅ Completed
Silver Layer	✅ Completed
Gold Layer	🔄 Upcoming
Exploratory Data Analysis	⏳ Upcoming
Advanced Analytics	⏳ Upcoming


🎯 Project Goals
By the end of this project, the goal is to build a complete SQL Server
Data Warehouse pipeline from raw source data to analytical insights.
The project will demonstrate practical experience with:
- ETL development
- Data cleaning
- Data transformation
- Data modeling
- Fact and dimension tables
- Star schema design
- Data quality validation
- Analytical SQL
- Business-oriented reporting
📈 Final Data Flow
             ┌─────────────────┐
             │   CRM Sources   │
             └────────┬────────┘
                      │
                      │
             ┌────────▼────────┐
             │  Bronze Layer   │
             │  Raw Data       │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │  Silver Layer   │
             │ Cleaned Data    │
             │ Standardized    │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │   Gold Layer    │
             │ Business Ready  │
             │ Star Schema     │
             └────────┬────────┘
                      │
                      ▼
             ┌─────────────────┐
             │    Analytics    │
             │   & Reporting   │
             └─────────────────┘

             ┌─────────────────┐
             │   ERP Sources   │
             └────────┬────────┘
                      │
                      └───────────────► Bronze

👨‍💻 Project Development Approach
This project is being developed incrementally.
Each layer is:
1. Designed
2. Implemented
3. Loaded
4. Validated
5. Documented
6. Added to GitHub
The project will continue from the Silver layer into the Gold layer,
followed by exploratory data analysis and advanced analytics.
✅ Current Status
Bronze Layer: Completed and validated
Silver Layer: Completed and validated
Gold Layer: Upcoming
Analytics: Upcoming
⭐ Final Objective
Build an end-to-end SQL Server Data Warehouse that demonstrates the
complete journey from raw source data to clean, structured,
business-ready analytical data.
