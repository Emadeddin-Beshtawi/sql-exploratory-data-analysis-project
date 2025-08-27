/*
===============================================================================
Bronze Layer — DDL (Annotated)
===============================================================================
Purpose
  - Define raw/landing tables in schema [bronze] that mirror source CSVs as-is:
      - CRM:    cust_info.csv, prd_info.csv, sales_details.csv
      - ERP:    LOC_A101.csv, CUST_AZ12.csv, PX_CAT_G1V2.csv
  - Drop existing tables (if present) to allow re-definition during development.

Scope & Behavior
  - Destructive for dev convenience: IF OBJECT_ID(...) DROP TABLE ... then CREATE TABLE.
  - Column names/types reflect source fields with minimal transformation (Bronze principle).

Conventions checked
  - Schema: [bronze]
  - Naming: <source>_<entity>  (e.g., crm_cust_info, erp_loc_a101), snake_case
  - No audit/system columns here (pure raw). Consider adding later if needed for lineage.

Design notes (non-blocking)
  - Monetary/price fields are INT here (kept raw). For analytics, Silver/Gold can cast to DECIMAL.
  - Date fields provided as INT in sales_details (likely yyyymmdd). Silver can convert to DATE.

Change Log
  - 2025-08-23: Added annotations without changing behavior.
===============================================================================
*/

-- ---------------------------------------------------------------------------
-- CRM: Customer Info (cust_info.csv) -> bronze.crm_cust_info
-- Raw customer master attributes as delivered by CRM.
-- ---------------------------------------------------------------------------
USE DataWarehouse;
GO
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO

CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,            -- customer_id (numeric identifier)
    cst_key             NVARCHAR(50),   -- customer_number / business key (text)
    cst_firstname       NVARCHAR(50),   -- given name
    cst_lastname        NVARCHAR(50),   -- family name
    cst_marital_status  NVARCHAR(50),   -- 'Married','Single','...'
    cst_gndr            NVARCHAR(50),   -- 'Male','Female','n/a', etc.
    cst_create_date     DATE            -- creation date (already DATE here)
);
GO

-- ---------------------------------------------------------------------------
-- CRM: Product Info (prd_info.csv) -> bronze.crm_prd_info
-- Raw product catalog attributes as delivered by CRM.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO

CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,            -- product_id (numeric identifier)
    prd_key      NVARCHAR(50),   -- product_number / business key
    prd_nm       NVARCHAR(50),   -- product_name (short description)
    prd_cost     INT,            -- base cost; kept INT in Bronze (Silver may cast to DECIMAL(18,2))
    prd_line     NVARCHAR(50),   -- product_line, e.g., 'Road','Mountain'
    prd_start_dt DATETIME,       -- start date/time in catalog
    prd_end_dt   DATETIME        -- end date/time in catalog (nullable if active)
);
GO

-- ---------------------------------------------------------------------------
-- CRM: Sales Details (sales_details.csv) -> bronze.crm_sales_details
-- Raw sales line items. Several date-like fields are integers (likely yyyymmdd).
-- Silver layer should convert these to DATE and standardize amounts.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  NVARCHAR(50),   -- order_number (e.g., 'SO54496')
    sls_prd_key  NVARCHAR(50),   -- product business key (to map to product)
    sls_cust_id  INT,            -- customer_id (numeric)
    sls_order_dt INT,            -- order date as INT (e.g., 20130612); Silver will CAST/CONVERT
    sls_ship_dt  INT,            -- ship date as INT
    sls_due_dt   INT,            -- due date as INT
    sls_sales    INT,            -- sales_amount (kept INT; Silver/Gold may use DECIMAL)
    sls_quantity INT,            -- quantity (units)
    sls_price    INT             -- unit price (kept INT)
);
GO

-- ---------------------------------------------------------------------------
-- ERP: Location (LOC_A101.csv) -> bronze.erp_loc_a101
-- Country mapping keyed by a customer/location id (cid).
-- ---------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO

CREATE TABLE bronze.erp_loc_a101 (
    cid    NVARCHAR(50),   -- id that joins to ERP customer/location ref
    cntry  NVARCHAR(50)    -- country name (e.g., 'Australia')
);
GO

-- ---------------------------------------------------------------------------
-- ERP: Customer Demographics (CUST_AZ12.csv) -> bronze.erp_cust_az12
-- Supplemental attributes for customers (birth date, gender).
-- ---------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO

CREATE TABLE bronze.erp_cust_az12 (
    cid    NVARCHAR(50),   -- id that links to CRM/ERP person (to be standardized in Silver)
    bdate  DATE,           -- birthdate (already DATE)
    gen    NVARCHAR(50)    -- gender text ('Male','Female','n/a', etc.)
);
GO

-- ---------------------------------------------------------------------------
-- ERP: Product Category (PX_CAT_G1V2.csv) -> bronze.erp_px_cat_g1v2
-- Product category metadata (category/subcategory and maintenance flag).
-- ---------------------------------------------------------------------------

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           NVARCHAR(50),   -- product key/code (links to CRM product)
    cat          NVARCHAR(50),   -- category (e.g., Bikes, Components)
    subcat       NVARCHAR(50),   -- subcategory (e.g., Mountain, Road)
    maintenance  NVARCHAR(50)    -- 'Yes'/'No' as text; Silver can normalize to BIT/BOOLEAN
);
GO
