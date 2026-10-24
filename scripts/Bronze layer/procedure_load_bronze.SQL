/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.

    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.

    This stored procedure does not accept any parameters or return any values.

Usage Example:

    EXEC bronze.load_bronze;

===============================================================================
*/

create or alter procedure bronze.load_bronze as
begin
  DECLARE @start_time DATETIME,@end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
  begin try
    set @batch_start_time = GETDATE()
    print '===============================================================================================================';
    print 'Loading Bronze layer';
    print '===============================================================================================================';

    print '---------------------------------------------------------------------------------------------------------------';
    print 'Loading crm tables';
    -- DML
    --table 1
    set @start_time = getdate();
    -- refresh first by truncate then bulk insert
    print '>> Truncating table : bronze.crm_cust_info'
    truncate table bronze.crm_cust_info
    -- bulk insert of data in table
    print '>> Inserting Data into : bronze.crm_cust_info'
    bulk insert bronze.crm_cust_info
    from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    with(
    firstrow = 2,
    fieldterminator = ',',
    tablock
    )
    set @end_time = getdate();
    PRINT 'crm_cust_info Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';
    -- data quality check 
--    select * from bronze.crm_cust_info
    select count(*) from bronze.crm_cust_info

    --table 2
    set @start_time = getdate();
    -- refresh first by truncate then bulk insert
    print '>> Truncating table : bronze.crm_prd_info'
    truncate table bronze.crm_prd_info
    -- bulk insert of data in table
    print '>> Inserting Data into : bronze.crm_sales_details'
    bulk insert bronze.crm_prd_info
    from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    with(
    firstrow = 2,
    fieldterminator = ',',
    tablock
    )
    set @end_time = getdate();
    PRINT 'crm_bronze_prd_info Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';
    -- data quality check 
--    select * from bronze.crm_prd_info
    select count(*) from bronze.crm_prd_info

    --table 3
    set @start_time = getdate();
    -- refresh first by truncate then bulk insert
    print '>> Truncating table : bronze.crm_sales_details'
    truncate table bronze.crm_sales_details
    -- bulk insert of data in table
    print '>> Inserting Data into : bronze.crm_sales_details'
    bulk insert bronze.crm_sales_details
    from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    with(
    firstrow = 2,
    fieldterminator = ',',
    tablock
    )
    set @end_time = getdate();
    PRINT 'crm_bronze_sales_details Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';
    -- data quality check 
--    select * from bronze.crm_sales_details
    select count(*) from bronze.crm_sales_details


    print '---------------------------------------------------------------------------------------------------------------';
    print 'Loading erp tables';
    --table 4
    set @start_time = getdate();
    -- refresh first by truncate then bulk insert
    print '>> Truncating table : bronze.erp_loc_a101'
    truncate table bronze.erp_loc_a101
    -- bulk insert of data in table
    print '>> Inserting Data into : bronze.erp_loc_a101'
    bulk insert bronze.erp_loc_a101
    from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
    with(
    firstrow = 2,
    fieldterminator = ',',
    tablock
    )
    set @end_time = getdate();
    PRINT 'erp_bronze_loc_a101 Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';
   -- data quality check 
--   select * from bronze.erp_loc_a101
   select count(*) from bronze.erp_loc_a101

   --table 5
   set @start_time = getdate();
   -- refresh first by truncate then bulk insert
   print '>> Truncating table : bronze.erp_cust_az12'
   truncate table bronze.erp_cust_az12
   -- bulk insert of data in table
   print '>> Inserting Data into : bronze.erp_cust_az12'
   bulk insert bronze.erp_cust_az12
   from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
   with(
   firstrow = 2,
   fieldterminator = ',',
   tablock
   )
   set @end_time = getdate();
   PRINT 'erp_bronze_cust_az12 Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';

   -- data quality check 
--   select * from bronze.erp_cust_az12
   select count(*) from bronze.erp_cust_az12

   --table 6
   set @start_time = getdate();
   -- refresh first by truncate then bulk insert
   print '>> Truncating table : bronze.erp_px_cat_g1v2'
   truncate table bronze.erp_px_cat_g1v2
   -- bulk insert of data in table
   print '>> Inserting Data into : bronze.erp_px_cat_g1v2'
   bulk insert bronze.erp_px_cat_g1v2
   from 'C:\Users\ayyu1\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
   with(
   firstrow = 2,
   fieldterminator = ',',
   tablock
   )
   set @end_time = getdate();
   PRINT 'erp_bronze.erp_px_cat_g1v2 Load Time: ' + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR) + ' ms';
   -- data quality check 
--   select * from bronze.erp_px_cat_g1v2
   select count(*) from bronze.erp_px_cat_g1v2

   set @batch_end_time = GETDATE();
   print '-------------------'
   print 'Loading bronze layer is completed' 
   print 'Total Duration:' + CAST(DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time) AS VARCHAR) + 'MS'
   print '-------------------'
  end try
  begin catch
   print '======================================='
   print 'error meassage' + error_message();
   print 'error number' + cast(error_number() as nvarchar);
   print 'error state' + cast(error_state() as nvarchar);
   print '======================================='
  end catch
end

