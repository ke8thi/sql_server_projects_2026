/*
================================================================================
bronze layer - table creation
================================================================================

purpose:
    create the six raw bronze tables used to store data from the crm and erp
    source systems.

bronze layer principle:
    raw source data is loaded with minimal transformation.
================================================================================
*/


/*
================================================================================
crm customer
================================================================================
*/

create table bronze.crm_cust_info
(
    cst_id int,
    cst_key varchar(50),
    cst_firstname varchar(50),
    cst_lastname varchar(50),
    cst_marital_status varchar(15),
    cst_gndr varchar(10),
    cst_create_date date
);


/*
================================================================================
crm product
================================================================================
*/

create table bronze.crm_prd_info
(
    prd_id int,
    prd_key varchar(100),
    prd_nm varchar(100),
    prd_cost int,
    prd_line varchar(15),
    prd_start_dt date,
    prd_end_dt date
);


/*
================================================================================
crm sales
================================================================================
*/

create table bronze.crm_sales_details
(
    sls_ord_num varchar(50),
    sls_prd_key varchar(50),
    sls_cust_id int,
    sls_order_dt varchar(50),
    sls_ship_dt varchar(50),
    sls_due_dt varchar(50),
    sls_sales int,
    sls_quantity int,
    sls_price int
);


/*
================================================================================
erp customer
================================================================================
*/

create table bronze.erp_cust_az12
(
    cid varchar(100),
    bdate date,
    gen varchar(50)
);


/*
================================================================================
erp location
================================================================================
*/

create table bronze.erp_loc_a101
(
    cid varchar(100),
    cntry varchar(100)
);


/*
================================================================================
erp product category
================================================================================
*/

create table bronze.erp_px_cat_g1v2
(
    id varchar(50),
    cat varchar(100),
    subcat varchar(100),
    maintenance varchar(20)
);
