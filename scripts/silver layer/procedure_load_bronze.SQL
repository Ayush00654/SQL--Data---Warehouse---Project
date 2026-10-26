/*
====================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
====================================================================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.

    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.

    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;

====================================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    DECLARE @start_time DATETIME,
            @end_time DATETIME,
            @batch_start_time DATETIME,
            @batch_end_time DATETIME

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '===============================================================================================================';
        PRINT 'Loading Silver Layer';
        PRINT '===============================================================================================================';

        ---------------------------------------------------------------------------------------------------------------
        PRINT 'Loading CRM Tables';
        ---------------------------------------------------------------------------------------------------------------

        -- CRM CUSTOMER INFO
        SET @start_time = GETDATE();
print '>> Truncate Table: silver.crm_cust_info';
Truncate Table silver.crm_cust_info;
print '>> Inserting Data Into : silver.crm_cust_info'
insert into silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)
select 
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status)) = 'S' then 'Single'
     when upper(trim(cst_marital_status)) = 'M' then 'Married'
     else 'N/A'
     end cst_marital_status,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
     when upper(trim(cst_gndr)) = 'M' then 'Male'
     else 'N/A'
     end cst_gndr,
cst_create_date

from (
      select *,ROW_NUMBER() over (partition by cst_id order by cst_create_date DESC) as flag_last
      from bronze.crm_cust_info 
      ) t where flag_last = 1

SET @end_time = GETDATE();

   PRINT 'silver.crm_cust_info Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';
        ---------------------------------------------------------------------------------------------------------------
        -- CRM PRODUCT INFO
        ---------------------------------------------------------------------------------------------------------------

        SET @start_time = GETDATE();

print '>> Truncate Table: silver.crm_prd_info';
Truncate Table silver.crm_prd_info;
print '>> Inserting Data Into : silver.crm_prd_info'
INSERT INTO silver.crm_prd_info (
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
replace(substring(prd_key, 1, 5), '-', '_' )as cat_id,
substring(prd_key, 7, len(prd_key)) as prd_key,
prd_nm,
isnull(prd_cost, 0) as prd_cost,
case upper(trim(prd_line))
     when 'M' then 'Mountain'
     when 'R' then 'Road'
     when 'S' then 'Other Sales'
     when 'T' then 'touring'
     else 'N/A'
     end prd_line,
cast (prd_start_dt as date) as prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
from bronze.crm_prd_info;

SET @end_time = GETDATE();

        PRINT 'silver.crm_prd_info Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';

        ---------------------------------------------------------------------------------------------------------------
        -- CRM SALES DETAILS
        ---------------------------------------------------------------------------------------------------------------

        SET @start_time = GETDATE();

print '>> Truncate Table: silver.crm_sales_details';
Truncate Table silver.crm_sales_details;
print '>> Inserting Data Into : silver.crm_sales_details';
INSERT INTO silver.crm_sales_details
(
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
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
case when sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 then null
     else cast(cast(sls_order_dt as varchar) as date)
end as sls_order_dt,

case when sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 then null
     else cast(cast(sls_ship_dt as varchar) as date)
end as sls_ship_dt,
case when sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 then null
     else cast(cast(sls_due_dt as varchar) as date)
end as sls_due_dt,
case when sls_sales != sls_quantity * abs(sls_price) or sls_sales <= 0 or sls_sales is null
     then sls_quantity * abs(sls_price)
     else sls_sales
     end as sls_sales,
sls_quantity,
case when sls_price is null or sls_price <= 0 then sls_sales/nullif(sls_quantity, 0)
     else sls_price
     end as sls_price
FROM bronze.crm_sales_details;

SET @end_time = GETDATE();

        PRINT 'silver.crm_sales_details Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';


        ---------------------------------------------------------------------------------------------------------------
        PRINT 'Loading ERP Tables';
        ---------------------------------------------------------------------------------------------------------------

        -- ERP CUSTOMER

        SET @start_time = GETDATE();

print '>> Truncate Table: silver.erp_cust_az12';
Truncate Table silver.erp_cust_az12;
print '>> Inserting Data Into : silver.erp_cust_az12';
INSERT INTO silver.erp_cust_az12
(
    CID,
    BDATE,
    GEN
)
select 
case when cid like 'NAS%' then substring(cid, 4, len(cid))
     else cid
     end cid,
case when bdate > getdate() then null
     else bdate 
     end bdate,
case
    when upper(trim(gen)) in ('M','MALE') then 'Male'
    when upper(trim(gen)) in ('F','FEMALE') then 'Female'
    else 'N/A'       
end as gen
from bronze.erp_cust_az12

SET @end_time = GETDATE();

        PRINT 'silver.erp_cust_az12 Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';


        ---------------------------------------------------------------------------------------------------------------
        -- ERP LOCATION
        ---------------------------------------------------------------------------------------------------------------

        SET @start_time = GETDATE();
PRINT '>> Truncate Table : silver.erp_loc_a101';
TRUNCATE TABLE silver.erp_loc_a101;
PRINT '>> Inserting Data Into : silver.erp_loc_a101';
INSERT INTO silver.erp_loc_a101
(
    CID,
    CNTRY
)
select 
replace(cid, '-', ''),
case when trim(cntry) = 'DE' then 'Germany'
     when trim(cntry) in ('US', 'USA') then 'United States'
     when cntry is null or trim(cntry) = '' then 'N/A'
     else trim(cntry)
     end cntry
from bronze.erp_loc_a101

SET @end_time = GETDATE();

        PRINT 'silver.erp_loc_a101 Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';

        ---------------------------------------------------------------------------------------------------------------
        -- ERP CATEGORY
        ---------------------------------------------------------------------------------------------------------------

        SET @start_time = GETDATE();

print '>> Truncate Table: silver.erp_px_cat_g1v2';
Truncate Table silver.erp_px_cat_g1v2;
print '>> Inserting Data Into : silver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2
(
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
)
SELECT
    ID,
    CAT,
    SUBCAT,
    MAINTENANCE
FROM bronze.erp_px_cat_g1v2;

SET @end_time = GETDATE();

        PRINT 'silver.erp_px_cat_g1v2 Load Time : '
              + CAST(DATEDIFF(MILLISECOND,@start_time,@end_time) AS VARCHAR)
              + ' ms';


        ---------------------------------------------------------------------------------------------------------------
        -- BATCH COMPLETED
        ---------------------------------------------------------------------------------------------------------------

        SET @batch_end_time = GETDATE();

        PRINT '-----------------------------';
        PRINT 'Loading Silver Layer Completed';
        PRINT 'Total Duration : '
              + CAST(DATEDIFF(MILLISECOND,@batch_start_time,@batch_end_time) AS VARCHAR)
              + ' ms';
        PRINT '-----------------------------';

    END TRY

    BEGIN CATCH

        PRINT '=======================================';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS VARCHAR);
        PRINT '=======================================';

    END CATCH

END
GO
