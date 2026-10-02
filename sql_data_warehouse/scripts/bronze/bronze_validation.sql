/*
================================================================================
bronze layer - validation
================================================================================

purpose:
    validate that the bronze tables were loaded successfully.

checks:
    1. execute bronze loading procedure
    2. validate row counts
    3. validate NULL values
================================================================================
*/


/*
================================================================================
step 1: execute bronze loading procedure
================================================================================
*/

exec bronze.load_bronze;


/*
================================================================================
step 2: validate row counts
================================================================================
*/

select 'crm_cust_info' as table_name, count(*) as row_count
from bronze.crm_cust_info

union all

select 'crm_prd_info', count(*)
from bronze.crm_prd_info

union all

select 'crm_sales_details', count(*)
from bronze.crm_sales_details

union all

select 'erp_cust_az12', count(*)
from bronze.erp_cust_az12

union all

select 'erp_loc_a101', count(*)
from bronze.erp_loc_a101

union all

select 'erp_px_cat_g1v2', count(*)
from bronze.erp_px_cat_g1v2;


/*
================================================================================
step 3: validate NULL values in customer data
================================================================================

NULL values are checked here for data-quality analysis.

we do not clean the NULL values in the bronze layer.
================================================================================
*/

select
    count(*) as total_rows,

    sum(case
            when cst_id is null then 1
            else 0
        end) as null_cst_id,

    sum(case
            when cst_key is null then 1
            else 0
        end) as null_cst_key,

    sum(case
            when cst_firstname is null then 1
            else 0
        end) as null_firstname,

    sum(case
            when cst_lastname is null then 1
            else 0
        end) as null_lastname

from bronze.crm_cust_info;
