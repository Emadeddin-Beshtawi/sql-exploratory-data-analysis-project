/*
===============================================================================
Silver Layer — Quality Checks (Annotated)
===============================================================================
Purpose
  - Validate data quality after loading the Silver layer:
      • Nulls/duplicates on natural keys
      • Unwanted whitespace
      • Standardization domains (e.g., gender, marital_status, country)
      • Date validity and ordering
      • Cross-field consistency (e.g., sales = quantity * price)
  - Includes one Bronze pre-check for raw integer dates (source sanity).

Usage
  - Run after executing: EXEC silver.load_silver;
  - Investigate any returned rows; empty resultsets mean "pass" for that check.

Notes
  - TRIM requires SQL Server 2017+.
  - Some checks intentionally SELECT DISTINCT domains (to visually inspect values).
===============================================================================
*/
USE DataWarehouse;
GO

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Duplicates or NULLs in the (natural) key cst_id.
-- Expectation: No rows.
SELECT 
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces in business key.
-- Expectation: No rows.
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Domain of marital_status after standardization.
-- Expectation: Values like 'Married','Single','n/a'.
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Duplicates or NULLs in prd_id.
-- Expectation: No rows.
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Unwanted spaces in product name.
-- Expectation: No rows.
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- NULL or negative cost.
-- Expectation: No rows.
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Domain of product line after mapping.
-- Expectation: 'Mountain','Road','Other Sales','Touring','n/a'.
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Invalid effective dating: end date before start date.
-- Expectation: No rows.
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Pre-check on Bronze: raw INT dates that look invalid.
-- Expectation: No invalids (or known exceptions to handle).
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Order date must be <= ship/due dates.
-- Expectation: No rows.
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Cross-field consistency: sales = quantity * price; all positive and non-null.
-- Expectation: No rows.
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Out-of-range birthdates (simple guardrail).
-- Expectation: Between 1924-01-01 and today.
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Domain of gender after normalization.
-- Expectation: 'Female','Male','n/a'.
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Domain of country values post-normalization.
-- Expectation: Expanded codes (e.g., 'Germany','United States','n/a', etc.).
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Unwanted spaces in category fields.
-- Expectation: No rows.
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Domain for maintenance flag.
-- Expectation: e.g., 'Yes','No' (or other values as per source), to be standardized later.
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
