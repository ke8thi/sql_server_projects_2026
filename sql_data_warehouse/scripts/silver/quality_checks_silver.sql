/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs data quality checks on the Silver layer
    after the data loading process.

    The checks validate:
        - Null values
        - Duplicate records
        - Data standardization
        - Invalid values
        - Date consistency
        - Business-rule consistency

    Expected Result:
        All issue counts should be 0.

    Layer:
        Silver
===============================================================================
*/


-- ============================================================================
-- 1. Customer Checks
-- ============================================================================

-- Check for NULL customer IDs
select
    'customer_null_id' as check_name,
    count(*) as issue_count
from silver.crm_cust_info
where cst_id is null;


-- Check for duplicate customer IDs
select
    'customer_duplicate_id' as check_name,
    count(*) as issue_count
from (
    select cst_id
    from silver.crm_cust_info
    group by cst_id
    having count(*) > 1
) t;


-- Check for leading/trailing spaces in first names
select
    'customer_firstname_spaces' as check_name,
    count(*) as issue_count
from silver.crm_cust_info
where cst_firstname <> trim(cst_firstname);


-- Check for leading/trailing spaces in last names
select
    'customer_lastname_spaces' as check_name,
    count(*) as issue_count
from silver.crm_cust_info
where cst_lastname <> trim(cst_lastname);


-- Check for invalid marital status values
select
    'customer_invalid_marital_status' as check_name,
    count(*) as issue_count
from silver.crm_cust_info
where cst_marital_status not in ('Single', 'Married', 'n/a');


-- Check for invalid gender values
select
    'customer_invalid_gender' as check_name,
    count(*) as issue_count
from silver.crm_cust_info
where cst_gndr not in ('Male', 'Female', 'n/a');


-- ============================================================================
-- 2. Product Checks
-- ============================================================================

-- Check for NULL product IDs
select
    'product_null_id' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_id is null;


-- Check for duplicate product IDs
select
    'product_duplicate_id' as check_name,
    count(*) as issue_count
from (
    select prd_id
    from silver.crm_prd_info
    group by prd_id
    having count(*) > 1
) t;


-- Check for NULL product category IDs
select
    'product_null_cat_id' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where cat_id is null;


-- Check for NULL product keys
select
    'product_null_key' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_key is null;


-- Check for NULL product costs
select
    'product_null_cost' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_cost is null;


-- Check for negative product costs
select
    'product_negative_cost' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_cost < 0;


-- Check for invalid product line values
select
    'product_invalid_line' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_line not in (
    'Mountain',
    'Road',
    'Other Sales',
    'Touring',
    'n/a'
);


-- Check for NULL product start dates
select
    'product_null_start_date' as check_name,
    count(*) as issue_count
from silver.crm_prd_info
where prd_start_dt is null;


-- Check calculated product end dates
select
    'product_incorrect_end_date' as check_name,
    count(*) as issue_count
from (
    select
        prd_key,
        prd_start_dt,
        prd_end_dt,
        lead(prd_start_dt) over (
            partition by prd_key
            order by prd_start_dt
        ) as next_start_date
    from silver.crm_prd_info
) t
where prd_end_dt <> dateadd(day, -1, next_start_date)
  and next_start_date is not null;


-- ============================================================================
-- 3. Sales Checks
-- ============================================================================

-- Check for NULL order numbers
select
    'sales_null_order_number' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_ord_num is null;


-- Check for NULL product keys
select
    'sales_null_product_key' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_prd_key is null;


-- Check for NULL customer IDs
select
    'sales_null_customer_id' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_cust_id is null;


-- Check for invalid sales values
select
    'sales_invalid_sales' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_sales <= 0;


-- Check for invalid quantities
select
    'sales_invalid_quantity' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_quantity <= 0;


-- Check for invalid prices
select
    'sales_invalid_price' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_price <= 0;


-- Check sales calculation consistency
select
    'sales_calculation_mismatch' as check_name,
    count(*) as issue_count
from silver.crm_sales_details
where sls_sales <> sls_quantity * sls_price;


-- ============================================================================
-- 4. ERP Customer Checks
-- ============================================================================

-- Check for NULL customer IDs
select
    'erp_customer_null_id' as check_name,
    count(*) as issue_count
from silver.erp_cust_az12
where cid is null;


-- Check for NAS prefix that should have been removed
select
    'erp_customer_nas_prefix' as check_name,
    count(*) as issue_count
from silver.erp_cust_az12
where cid like 'NAS%';


-- Check for future birth dates
select
    'erp_customer_future_birthdate' as check_name,
    count(*) as issue_count
from silver.erp_cust_az12
where bdate > getdate();


-- Check for invalid gender values
select
    'erp_customer_invalid_gender' as check_name,
    count(*) as issue_count
from silver.erp_cust_az12
where gen not in ('Male', 'Female', 'n/a');


-- ============================================================================
-- 5. ERP Location Checks
-- ============================================================================

-- Check for NULL customer IDs
select
    'erp_location_null_id' as check_name,
    count(*) as issue_count
from silver.erp_loc_a101
where cid is null;


-- Check for hyphens in customer IDs
select
    'erp_location_cid_hyphen' as check_name,
    count(*) as issue_count
from silver.erp_loc_a101
where cid like '%-%';


-- Check for unstandardized DE country values
select
    'erp_location_unstandardized_de' as check_name,
    count(*) as issue_count
from silver.erp_loc_a101
where cntry = 'DE';


-- Check for unstandardized US country values
select
    'erp_location_unstandardized_us' as check_name,
    count(*) as issue_count
from silver.erp_loc_a101
where cntry in ('US', 'USA');


-- ============================================================================
-- 6. ERP Category Checks
-- ============================================================================

-- Check for NULL category IDs
select
    'erp_category_null_id' as check_name,
    count(*) as issue_count
from silver.erp_px_cat_g1v2
where id is null;


-- Check for duplicate category IDs
select
    'erp_category_duplicate_id' as check_name,
    count(*) as issue_count
from (
    select id
    from silver.erp_px_cat_g1v2
    group by id
    having count(*) > 1
) t;


-- ============================================================================
-- Expected Result
-- ============================================================================
-- Every check above should return:
--
-- issue_count = 0
--
-- If any check returns a value greater than 0,
-- investigate the corresponding transformation in the Silver load procedure.
