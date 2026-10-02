/*
================================================================================
bronze layer - data loading procedure
================================================================================

purpose:
    - load raw data from crm and erp source csv files into the bronze layer
    - preserve source data with minimal transformation
    - measure loading time for each table
    - measure total bronze loading time
    - handle errors using try/catch

process:
    source csv files
            ↓
        truncate bronze tables
            ↓
        bulk insert source data
            ↓
        measure load duration
            ↓
        validate loaded data
================================================================================
*/


/*==============================================================================
step 1: create or alter the stored procedure
==============================================================================*/

create or alter procedure bronze.load_bronze as
begin

    /*
    ============================================================================
    step 2: error handling
    ============================================================================
    try block contains the complete bronze loading process.

    if an error occurs anywhere inside this block, execution moves to
    the catch block at the bottom.
    */

    begin try


        /*
        ============================================================================
        step 3: declare timing variables
        ============================================================================
        @batch_start_time  -> when the complete bronze loading starts
        @batch_end_time    -> when the complete bronze loading finishes

        @start_time        -> when an individual table starts loading
        @end_time          -> when an individual table finishes loading
        */

        declare @batch_start_time datetime,
                @batch_end_time datetime,
                @start_time datetime,
                @end_time datetime;


        /*
        ============================================================================
        step 4: start the batch timer
        ============================================================================
        getdate() returns the current date and time.

        this timestamp will later be compared with @batch_end_time
        to calculate the total bronze loading duration.
        */

        set @batch_start_time = getdate();


        /*
        ============================================================================
        step 5: display bronze loading information
        ============================================================================
        print statements make the execution easier to monitor in the
        sql server messages/output window.
        */

        print '================================================';
        print 'loading bronze layer';
        print '================================================';


        /*
        ============================================================================
        step 6: start loading crm tables
        ============================================================================
        crm = customer relationship management
        */

        print '------------------------------------------------';
        print 'loading crm tables';
        print '------------------------------------------------';


        /*==========================================================================
        step 7: load crm customer table
        ==========================================================================*/

        -- start timer for crm customer table
        set @start_time = getdate();

        -- remove previously loaded bronze data
        -- bronze uses a full refresh in this project
        print '>> truncating table: bronze.crm_cust_info';

        truncate table bronze.crm_cust_info;

        -- load raw customer data from the source csv file
        print '>> inserting data into: bronze.crm_cust_info';

        bulk insert bronze.crm_cust_info
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        -- stop timer after the table has finished loading
        set @end_time = getdate();

        -- calculate and display table loading duration
        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*==========================================================================
        step 8: load crm product table
        ==========================================================================*/

        set @start_time = getdate();

        print '>> truncating table: bronze.crm_prd_info';

        truncate table bronze.crm_prd_info;

        print '>> inserting data into: bronze.crm_prd_info';

        bulk insert bronze.crm_prd_info
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();

        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*==========================================================================
        step 9: load crm sales table
        ==========================================================================*/

        set @start_time = getdate();

        print '>> truncating table: bronze.crm_sales_details';

        truncate table bronze.crm_sales_details;

        print '>> inserting data into: bronze.crm_sales_details';

        bulk insert bronze.crm_sales_details
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();

        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*
        ============================================================================
        step 10: start loading erp tables
        ============================================================================
        erp = enterprise resource planning
        */

        print '------------------------------------------------';
        print 'loading erp tables';
        print '------------------------------------------------';


        /*==========================================================================
        step 11: load erp customer table
        ==========================================================================*/

        set @start_time = getdate();

        print '>> truncating table: bronze.erp_cust_az12';

        truncate table bronze.erp_cust_az12;

        print '>> inserting data into: bronze.erp_cust_az12';

        bulk insert bronze.erp_cust_az12
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();

        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*==========================================================================
        step 12: load erp location table
        ==========================================================================*/

        set @start_time = getdate();

        print '>> truncating table: bronze.erp_loc_a101';

        truncate table bronze.erp_loc_a101;

        print '>> inserting data into: bronze.erp_loc_a101';

        bulk insert bronze.erp_loc_a101
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();

        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*==========================================================================
        step 13: load erp product category table
        ==========================================================================*/

        set @start_time = getdate();

        print '>> truncating table: bronze.erp_px_cat_g1v2';

        truncate table bronze.erp_px_cat_g1v2;

        print '>> inserting data into: bronze.erp_px_cat_g1v2';

        bulk insert bronze.erp_px_cat_g1v2
        from 'C:\Users\keerthireddy\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        with
        (
            firstrow = 2,
            fieldterminator = ',',
            tablock
        );

        set @end_time = getdate();

        print '>> load duration: '
              + cast(datediff(second, @start_time, @end_time) as varchar)
              + ' seconds';


        /*
        ============================================================================
        step 14: calculate total bronze loading duration
        ============================================================================
        */

        set @batch_end_time = getdate();

        print '>> bronze duration: '
              + cast(datediff(second, @batch_start_time, @batch_end_time) as varchar)
              + ' seconds';


        /*
        ============================================================================
        step 15: display successful completion message
        ============================================================================
        */

        print '================================================';
        print 'loading bronze layer is completed';
        print '================================================';


    /*
    ============================================================================
    step 16: error handling
    ============================================================================
    if any error occurs inside the try block, sql server moves here.

    error_message() -> description of the error
    error_number()  -> unique error number
    error_state()   -> state associated with the error
    */

    end try

    begin catch

        print '================================================';
        print 'error occurred during bronze loading';

        print 'error message: ' + error_message();

        print 'error number: '
              + cast(error_number() as varchar);

        print 'error state: '
              + cast(error_state() as varchar);

        print '================================================';

    end catch;

end;


/*
================================================================================
step 17: execute the bronze loading procedure
================================================================================

this runs the complete bronze etl process.

the procedure:
    1. truncates all six bronze tables
    2. loads the six csv files
    3. measures individual load times
    4. measures total load time
    5. handles errors
================================================================================
*/

exec bronze.load_bronze;


/*
================================================================================
step 18: validate row counts
================================================================================

this checks whether all six bronze tables were loaded successfully.
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
step 19: validate NULL values
================================================================================

this checks important customer columns for NULL values.

important:
we are NOT cleaning these values here.

bronze should preserve the source data.
data cleaning and standardization will happen in the silver layer.
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
