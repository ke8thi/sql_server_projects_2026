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
- Set Operators
- SQL Functions
- CASE Statements
- Aggregate Functions
- Window Functions
- Subqueries
- CTEs
- Views
- Temporary Tables
- Stored Procedures
- Error Handling
- Bulk Data Loading
- Data Validation
- Data Warehouse Architecture
- ETL
🚧 Project Progress
Phase	Status
Project Setup	✅ Completed
Bronze Layer	✅ Completed
Silver Layer	🔄 Upcoming
Gold Layer	⏳ Upcoming
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
- Data quality validation
- Analytical SQL
- Business-oriented reporting

### One important thing bro

Your **root repository** can eventually look like:

```text
sql_server_projects_2026/
│
└── sql_data_warehouse/
    ├── scripts/
    │   ├── bronze/
    │   ├── silver/
    │   └── gold/
    │
    ├── docs/
    │
    └── README.md
