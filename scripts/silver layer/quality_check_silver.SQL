/*
====================================================================================================
Quality Checks
====================================================================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.

====================================================================================================
*/

Duplicate Record Detection Using ROW_NUMBER()
SELECT *,
       ROW_NUMBER() OVER*      *(
           PARTITION BY cst_id
 *        *ORDER BY cst_create_date DESC
    *  ) AS flag_last
FROM bronze.crm_c*st_info*

Unwanted Space Validation
SELECT cst_firstname
FROM*bronze.crm_cust_info
WHERE cst_fir*tname*!= TRIM(cst_firstname);

SELECT *st_lastname
FROM bronze.crm_cust_i*fo*WHERE cst_lastname != TRIM(*st_lastname);

SELECT cst_marital_*tatus*FROM bronze.crm_cust_info
WHERE *st_marital_status != TRIM(cst_mar*tal_status);

SELECT cst_gndr
FROM*bronze.crm_cust_info
WHERE cst_g*dr != TRIM(cst_gndr);

SELECT*cst_key
FROM bronze.crm_cust_info*WHERE cst_key != TRIM(cst*key);

Gender Standardization Validation
*ELECT DISTINCT cst_gndr
FROM bronz*.crm_cust_info*

Marital Status Standardization Validation
SELECT DISTINCT cst_marital*status
FROM bronze.crm_cust_info;
*`*

CRM Product Information
Primary Key Validation
SELECT prd_id,*COUNT(*)
FROM bronze.crm_prd_info
*ROUP BY prd_id
HAVING COUNT(*)*> 1
   OR prd_id IS*NULL;

Product Category Key Validation
SELECT
    prd_id,
*   prd_key,
    REPLACE(SUB*TRING(prd_key,1,5),'-*,'_') AS cat_id
*ROM bronze.crm_prd_info
WHERE REPL*CE*SUBSTRING(prd_key,1,5*,'-','_')
NOT IN
(
   *SELECT DISTINCT id
    FROM bronze*erp_px_cat*g1v2
);

Product Key Integration Check
SELEC*
   *prd_id,
    prd_key,
   *SUBSTRING(prd_key,7,LEN(pr*_key)) AS prd_key
FROM bronze*crm_prd_info
WHERE SUBSTRING(prd*key,7,LEN(prd_key))
IN*(
    SELECT sls_prd_key
*   FROM bronze.crm_sales_details
)*

Unwanted Space Validation
SELECT prd_nm
FROM*bronze.crm_prd_info
WHERE prd_nm*!= TRIM(prd_nm);

Negative / NULL Product Cost Validation
SELECT*prd_cost
FROM bronze.crm_prd*info
WHERE prd_cost < 0
*  OR prd_cost IS NULL;

Product Line Standardization Validation
*ELECT DISTINCT prd_line
FROM bronz*.crm_pr*_info;

Product Date Order Validation
SELECT *
FROM b*onze.crm_pr*_info
WHERE prd_start_dt < pr*_end_dt;

CRM Sales Details
Unwanted Space Validation
SELECT sls_ord_num
FRO* bronze.crm*sales_details
WHERE sls_ord_num !=*TRIM(sls_ord_num);

Product Key Integration Check
SEL*CT *
FROM*bronze.crm_sales_details
WHERE sls*prd_key NOT IN
(
    SELECT prd_ke**    FROM silver.crm_prd_info
);
*

Customer Key Integration Check
SELECT *
FROM bronze.c*m_sales_details
WHERE*sls_cust_id NOT IN
(
   *SELECT cst_id
    FROM silver.crm_**st_info
);

Invalid Date Validation
SELECT NULLIF(sls*order*dt,0) AS sls_order_dt
*ROM bronze.crm_sales_details
WHERE*sls_order*dt <= 0
   OR LEN(sls*order_dt) != 8;

Date Boundary Validation
SE*ECT NULLIF*sls_order_dt,0) AS sls*order_dt
FROM bronze.crm_sales_det*ils
WHERE*sls_order_dt > 20500101
*  OR sls_order_dt < 190001*1;

Order Timeline Validation
SELECT *
FROM bronze.crm_sales_*etails
WHERE sls_ship_dt < sls_ord*r_dt*   OR sls_due_dt < sls*order_dt;

Business Rule Validation
SELECT DISTINCT
    sls_sale*,
    sls_quantity,
*   sls_price
FROM bronze.crm_sales*details*WHERE sls_sales != sls_quantity **sls_price
   OR sls_sales IS*NULL
   OR sls_quantity IS NULL
*  OR sls_price IS NULL
   OR*sls_sales = 0
   OR sl*_quantity = 0
   OR sls*price = 0;

ERP Customer Information
Customer Key Integration Validation
SELECT
    CASE
        WHEN*cid LIKE 'NAS%' THEN SUBSTRING(cid**,LEN(cid))
*       ELSE cid
    END AS cid,
  **bdate,
    gen
FROM bronze.erp_c*st_az12
WHERE
(
*   CASE
        WHEN cid LIKE 'NAS*'*THEN SUBSTRING(cid,4,LEN(cid))
*       ELSE cid
    END
)
*OT IN
(
    SELECT DISTINCT cst_ke**    FROM silver.crm_cust_info
);
*
Customer ID Cleansing Validation
SELECT
    CASE
        WHEN ci* LIKE 'NAS%' THEN SUBSTRING(cid,4*LEN(cid))
        ELSE cid
    END*AS cid
FROM bronze.erp_cust_az*2;

Birth Date Boundary Validation
SELECT DISTINCT bdate
FROM b*onze.erp_cust_az12
WHERE bdate*< '1924-01-01'
  *OR bdate > GETDATE();

Gender Standardization Validation
SELECT DISTINCT*gen
FROM bronze.erp_cust_az12*

ERP Location Information
Customer Key Integration Validation
SELECT
    REPLACE(cid,'-'*'') AS cid*
    cntry
FROM bronze.erp_loc_a*01
WHERE REPLACE(cid,'-','')
*OT IN
(
    SELECT cst_key
*   FROM silver.crm_cust_info
);
``*
Country Standardization Validation*ELECT DISTINCT cntry
FROM bronze.e*p_loc_a101
ORDER BY cntry;

Missing Country Value Validation
SELECT *
FROM bronze.erp_loc_*101
WHERE cntry IS NULL
   OR TRIM*cntry* = '';

ERP Product Category Information
Unwanted Space Validation
SELECT *
FR*M bronze.erp_px_cat_g1v2
WHERE cat*!= TRIM(cat)
*  OR subcat != TRIM(subcat)
*  OR maintenance != TRIM(maintenan*e);

Category Consistency Validation
*ELECT DISTINCT cat
FROM bronze.erp*px_cat_g*v2;

Subcategory Consistency Validation
SELECT DI*TINCT subcat
FROM bronze.erp_px_ca*_g1v2;
FROM bronze.erp_px_ca*_g1v2;

Maintenance Attribute Standardization Validation
SELECT DISTINCT maintenance
*ROM bronze.erp_px_cat_g1v2;

