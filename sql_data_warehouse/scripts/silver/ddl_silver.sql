/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates the tables required for the Silver layer.

    The Silver layer stores cleansed, standardized, and transformed data
    loaded from the Bronze layer.

Actions Performed:
    - Creates the 'silver' schema.
    - Drops existing Silver tables if they already exist.
    - Creates six Silver layer tables.
    - Adds dwh_create_date to track warehouse load time.

Important:
    Run this script before executing the Silver layer load procedure.
===============================================================================
*/


/*
===============================================================================
Create Silver Schema
===============================================================================
*/

create schema silver;
go


/*
===============================================================================
Create: silver.crm_cust_info
Purpose:
    Stores cleansed and standardized customer information from
    bronze.crm_cust_info.
===============================================================================
*/

if object_id('silver.crm_cust_info', 'U') is not null
    drop table silver.crm_cust_info;
go

create table silver.crm_cust_info (
    cst_id             int,
    cst_key            nvarchar(50),
    cst_firstname      nvarchar(50),
    cst_lastname       nvarchar(50),
    cst_marital_status nvarchar(50),
    cst_gndr           nvarchar(50),
    cst_create_date    date,
    dwh_create_date    datetime2 default getdate()
);
go


/*
===============================================================================
Create: silver.crm_prd_info
Purpose:
    Stores cleansed and standardized product information from
    bronze.crm_prd_info.

    cat_id and the transformed product key are derived from the original
    Bronze product key during the Silver load process.
===============================================================================
*/

if object_id('silver.crm_prd_info', 'U') is not null
    drop table silver.crm_prd_info;
go

create table silver.crm_prd_info (
    prd_id          int,
    cat_id          nvarchar(50),
    prd_key         nvarchar(50),
    prd_nm          nvarchar(50),
    prd_cost        int,
    prd_line        nvarchar(50),
    prd_start_dt    date,
    prd_end_dt      date,
    dwh_create_date datetime2 default getdate()
);
go


/*
===============================================================================
Create: silver.crm_sales_details
Purpose:
    Stores cleansed and standardized sales transaction data from
    bronze.crm_sales_details.

    Date, sales, quantity, and price values are validated and transformed
    during the Silver loading process.
===============================================================================
*/

if object_id('silver.crm_sales_details', 'U') is not null
    drop table silver.crm_sales_details;
go

create table silver.crm_sales_details (
    sls_ord_num     nvarchar(50),
    sls_prd_key     nvarchar(50),
    sls_cust_id     int,
    sls_order_dt    date,
    sls_ship_dt     date,
    sls_due_dt      date,
    sls_sales       int,
    sls_quantity    int,
    sls_price       int,
    dwh_create_date datetime2 default getdate()
);
go


/*
===============================================================================
Create: silver.erp_loc_a101
Purpose:
    Stores standardized customer location information from
    bronze.erp_loc_a101.
===============================================================================
*/

if object_id('silver.erp_loc_a101', 'U') is not null
    drop table silver.erp_loc_a101;
go

create table silver.erp_loc_a101 (
    cid             nvarchar(50),
    cntry           nvarchar(50),
    dwh_create_date datetime2 default getdate()
);
go


/*
===============================================================================
Create: silver.erp_cust_az12
Purpose:
    Stores cleansed customer demographic information from
    bronze.erp_cust_az12.
===============================================================================
*/

if object_id('silver.erp_cust_az12', 'U') is not null
    drop table silver.erp_cust_az12;
go

create table silver.erp_cust_az12 (
    cid             nvarchar(50),
    bdate           date,
    gen             nvarchar(50),
    dwh_create_date datetime2 default getdate()
);
go


/*
===============================================================================
Create: silver.erp_px_cat_g1v2
Purpose:
    Stores ERP product category, subcategory, and maintenance information
    from bronze.erp_px_cat_g1v2.
===============================================================================
*/

if object_id('silver.erp_px_cat_g1v2', 'U') is not null
    drop table silver.erp_px_cat_g1v2;
go

create table silver.erp_px_cat_g1v2 (
    id              nvarchar(50),
    cat             nvarchar(50),
    subcat          nvarchar(50),
    maintenance     nvarchar(50),
    dwh_create_date datetime2 default getdate()
);
go
