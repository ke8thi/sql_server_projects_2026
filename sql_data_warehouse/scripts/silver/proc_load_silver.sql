/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process
    to populate the Silver layer tables from the Bronze layer.

Actions Performed:
    - Truncates existing Silver table data.
    - Extracts data from Bronze tables.
    - Cleanses and standardizes data.
    - Handles NULL and invalid values.
    - Removes duplicate customer records.
    - Derives product category and product keys.
    - Calculates product end dates using LEAD().
    - Loads transformed data into Silver tables.
    - Tracks individual and total load duration.
    - Handles errors using TRY...CATCH.

Parameters:
    None.

Usage Example:
    EXEC silver.load_silver;

===============================================================================
*/

create or alter procedure silver.load_silver
as
begin

    declare
        @start_time datetime,
        @end_time datetime,
        @batch_start_time datetime,
        @batch_end_time datetime;

    begin try

        /*
        =========================================================================
        Start Silver Layer Load
        =========================================================================
        */

        set @batch_start_time = getdate();

        print '================================================';
        print 'Loading Silver Layer';
        print '================================================';


        /*
        =========================================================================
        CRM TABLES
        =========================================================================
        */

        print '------------------------------------------------';
        print 'Loading CRM Tables';
        print '------------------------------------------------';


        /*
        =========================================================================
        Load: silver.crm_cust_info
        =========================================================================
        Transformations:
            - Remove NULL customer IDs.
            - Remove duplicate customer records.
            - Keep the most recent record for each customer.
            - Trim first and last names.
            - Standardize marital status.
            - Standardize gender.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.crm_cust_info';

        truncate table silver.crm_cust_info;

        print '>> Inserting Data Into: silver.crm_cust_info';

        insert into silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        select
            cst_id,
            cst_key,
            trim(cst_firstname) as cst_firstname,
            trim(cst_lastname) as cst_lastname,

            case
                when upper(trim(cst_marital_status)) = 'S'
                    then 'Single'
                when upper(trim(cst_marital_status)) = 'M'
                    then 'Married'
                else 'n/a'
            end as cst_marital_status,

            case
                when upper(trim(cst_gndr)) = 'F'
                    then 'Female'
                when upper(trim(cst_gndr)) = 'M'
                    then 'Male'
                else 'n/a'
            end as cst_gndr,

            cst_create_date

        from (
            select
                *,
                row_number() over (
                    partition by cst_id
                    order by cst_create_date desc
                ) as flag_last

            from bronze.crm_cust_info

            where cst_id is not null
        ) t

        where flag_last = 1;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        Load: silver.crm_prd_info
        =========================================================================
        Transformations:
            - Extract category ID from product key.
            - Extract product key.
            - Replace NULL product costs with 0.
            - Standardize product line values.
            - Convert product start date to DATE.
            - Calculate product end date using LEAD().
            
        Product End Date Logic:
            The end date of a product version is calculated as one day before
            the start date of the next version of the same product.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.crm_prd_info';

        truncate table silver.crm_prd_info;

        print '>> Inserting Data Into: silver.crm_prd_info';

        insert into silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        select
            prd_id,

            replace(
                substring(prd_key, 1, 5),
                '-',
                '_'
            ) as cat_id,

            substring(
                prd_key,
                7,
                len(prd_key)
            ) as prd_key,

            prd_nm,

            isnull(prd_cost, 0) as prd_cost,

            case
                when upper(trim(prd_line)) = 'M'
                    then 'Mountain'
                when upper(trim(prd_line)) = 'R'
                    then 'Road'
                when upper(trim(prd_line)) = 'S'
                    then 'Other Sales'
                when upper(trim(prd_line)) = 'T'
                    then 'Touring'
                else 'n/a'
            end as prd_line,

            cast(prd_start_dt as date) as prd_start_dt,

            cast(
                dateadd(
                    day,
                    -1,
                    lead(prd_start_dt) over (
                        partition by prd_key
                        order by prd_start_dt
                    )
                ) as date
            ) as prd_end_dt

        from bronze.crm_prd_info;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        Load: silver.crm_sales_details
        =========================================================================
        Transformations:
            - Convert valid integer dates into DATE values.
            - Convert invalid dates to NULL.
            - Recalculate invalid or missing sales values.
            - Convert negative prices to positive values.
            - Derive price when the source price is invalid.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.crm_sales_details';

        truncate table silver.crm_sales_details;

        print '>> Inserting Data Into: silver.crm_sales_details';

        insert into silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        select
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            case
                when sls_order_dt = 0
                     or len(sls_order_dt) != 8
                    then null
                else cast(cast(sls_order_dt as varchar) as date)
            end as sls_order_dt,

            case
                when sls_ship_dt = 0
                     or len(sls_ship_dt) != 8
                    then null
                else cast(cast(sls_ship_dt as varchar) as date)
            end as sls_ship_dt,

            case
                when sls_due_dt = 0
                     or len(sls_due_dt) != 8
                    then null
                else cast(cast(sls_due_dt as varchar) as date)
            end as sls_due_dt,

            case
                when sls_sales is null
                     or sls_sales <= 0
                     or sls_sales != sls_quantity * abs(sls_price)
                    then sls_quantity * abs(sls_price)
                else sls_sales
            end as sls_sales,

            sls_quantity,

            case
                when sls_price is null
                     or sls_price <= 0
                    then sls_sales / nullif(sls_quantity, 0)
                else sls_price
            end as sls_price

        from bronze.crm_sales_details;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        ERP TABLES
        =========================================================================
        */

        print '------------------------------------------------';
        print 'Loading ERP Tables';
        print '------------------------------------------------';


        /*
        =========================================================================
        Load: silver.erp_cust_az12
        =========================================================================
        Transformations:
            - Remove NAS prefix from customer IDs.
            - Replace future birth dates with NULL.
            - Standardize gender values.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.erp_cust_az12';

        truncate table silver.erp_cust_az12;

        print '>> Inserting Data Into: silver.erp_cust_az12';

        insert into silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        select

            case
                when cid like 'NAS%'
                    then substring(cid, 4, len(cid))
                else cid
            end as cid,

            case
                when bdate > getdate()
                    then null
                else bdate
            end as bdate,

            case
                when upper(trim(gen)) in ('F', 'FEMALE')
                    then 'Female'
                when upper(trim(gen)) in ('M', 'MALE')
                    then 'Male'
                else 'n/a'
            end as gen

        from bronze.erp_cust_az12;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        Load: silver.erp_loc_a101
        =========================================================================
        Transformations:
            - Remove hyphens from customer IDs.
            - Convert DE to Germany.
            - Convert US and USA to United States.
            - Convert NULL or blank countries to n/a.
            - Trim remaining country values.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.erp_loc_a101';

        truncate table silver.erp_loc_a101;

        print '>> Inserting Data Into: silver.erp_loc_a101';

        insert into silver.erp_loc_a101 (
            cid,
            cntry
        )
        select

            replace(cid, '-', '') as cid,

            case
                when trim(cntry) = 'DE'
                    then 'Germany'

                when trim(cntry) in ('US', 'USA')
                    then 'United States'

                when trim(cntry) = ''
                     or cntry is null
                    then 'n/a'

                else trim(cntry)
            end as cntry

        from bronze.erp_loc_a101;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        Load: silver.erp_px_cat_g1v2
        =========================================================================
        Transformations:
            - Copy product category information from Bronze to Silver.
            - No additional transformations are applied.
        =========================================================================
        */

        set @start_time = getdate();

        print '>> Truncating Table: silver.erp_px_cat_g1v2';

        truncate table silver.erp_px_cat_g1v2;

        print '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        insert into silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        select
            id,
            cat,
            subcat,
            maintenance
        from bronze.erp_px_cat_g1v2;

        set @end_time = getdate();

        print '>> Load Duration: '
            + cast(datediff(second, @start_time, @end_time) as nvarchar)
            + ' seconds';

        print '>> -------------';


        /*
        =========================================================================
        Silver Layer Load Completed
        =========================================================================
        */

        set @batch_end_time = getdate();

        print '==========================================';
        print 'Loading Silver Layer is Completed';

        print '   - Total Load Duration: '
            + cast(
                datediff(
                    second,
                    @batch_start_time,
                    @batch_end_time
                ) as nvarchar
            )
            + ' seconds';

        print '==========================================';


    end try


    /*
    =========================================================================
    Error Handling
    =========================================================================
    */

    begin catch

        print '==========================================';
        print 'ERROR OCCURED DURING LOADING SILVER LAYER';

        print 'Error Message: ' + error_message();

        print 'Error Number: '
            + cast(error_number() as nvarchar);

        print 'Error State: '
            + cast(error_state() as nvarchar);

        print '==========================================';

    end catch

end;
