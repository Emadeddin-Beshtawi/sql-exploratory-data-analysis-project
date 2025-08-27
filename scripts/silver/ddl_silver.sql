/*
===============================================================================
Silver Layer — DDL (Annotated)
===============================================================================
Purpose
  - Define cleaned/standardized tables in schema [silver] that closely mirror
    the bronze structures but:
      • normalize data types (e.g., INT → DATE where applicable),
      • add lightweight audit metadata (dwh_create_date).

Scope & Behavior
  - Dev-friendly re-definition: IF OBJECT_ID(...) DROP TABLE, then CREATE TABLE.
  - Column names remain source-aligned but standardized (snake_case).
  - No keys/constraints here by design (kept flexible for ingest); can be added later.

Notes
  - `dwh_create_date DEFAULT GETDATE()` uses server local time; for timezone
    consistency consider `SYSUTCDATETIME()` (kept as-is per your script).
  - Monetary fields remain INT here; we can shift to DECIMAL(18,2) in Gold.
  - `silver.crm_prd_info.cat_id` appears (not present in bronze); likely sourced
    from ERP category mapping. That’s acceptable in Silver as part of standardization.
  - Minor header typo in your original banner referencing “bronze” (left unchanged).

Change Log
  - 2025-08-23: Added annotations only.
===============================================================================
*/

-- ---------------------------------------------------------------------------
-- SILVER: CRM Customer Info
-- Cleaned customer master with load timestamp.
-- ---------------------------------------------------------------------------
USE DataWarehouse;
GO


IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id             INT,             -- numeric customer identifier
    cst_key            NVARCHAR(50),    -- business key / customer number
    cst_firstname      NVARCHAR(50),    -- given name
    cst_lastname       NVARCHAR(50),    -- family name
    cst_marital_status NVARCHAR(50),    -- standardized values expected in Silver
    cst_gndr           NVARCHAR(50),    -- standardized gender text
    cst_create_date    DATE,            -- already DATE at silver stage
    dwh_create_date    DATETIME2 DEFAULT GETDATE()  -- audit: row load timestamp
);
GO

-- ---------------------------------------------------------------------------
-- SILVER: CRM Product Info
-- Product catalog with normalized dates and optional category id (cat_id).
-- ---------------------------------------------------------------------------

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id          INT,             -- product numeric id
    cat_id          NVARCHAR(50),    -- category id (from ERP mapping downstream)
    prd_key         NVARCHAR(50),    -- product business key/code
    prd_nm          NVARCHAR(50),    -- product display/name
    prd_cost        INT,             -- cost kept as INT here (may become DECIMAL later)
    prd_line        NVARCHAR(50),    -- product line, e.g., 'Road','Mountain'
    prd_start_dt    DATE,            -- normalized from DATETIME in bronze
    prd_end_dt      DATE,            -- normalized from DATETIME in bronze
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- audit: row load timestamp
);
GO

-- ---------------------------------------------------------------------------
-- SILVER: CRM Sales Details
-- Transaction lines with dates normalized to DATE (from INT yyyymmdd in bronze).
-- ---------------------------------------------------------------------------

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num     NVARCHAR(50),    -- order number (e.g., 'SO54496')
    sls_prd_key     NVARCHAR(50),    -- product business key
    sls_cust_id     INT,             -- customer id (joins to crm_cust_info)
    sls_order_dt    DATE,            -- normalized date
    sls_ship_dt     DATE,            -- normalized date
    sls_due_dt      DATE,            -- normalized date
    sls_sales       INT,             -- sales amount kept as INT for now
    sls_quantity    INT,             -- quantity
    sls_price       INT,             -- unit price (INT; can cast later)
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- audit: row load timestamp
);
GO

-- ---------------------------------------------------------------------------
-- SILVER: ERP Location (country mapping)
-- Standardized country mapping with audit timestamp.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid             NVARCHAR(50),    -- identifier linking to person/customer
    cntry           NVARCHAR(50),    -- standardized country text
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- audit
);
GO

-- ---------------------------------------------------------------------------
-- SILVER: ERP Customer Demographics
-- Birthdate + gender with audit timestamp.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid             NVARCHAR(50),    -- identifier linking to customer/person
    bdate           DATE,            -- birthdate
    gen             NVARCHAR(50),    -- gender text (standardized in Silver)
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- audit
);
GO

-- ---------------------------------------------------------------------------
-- SILVER: ERP Product Category
-- Category/subcategory/mx flag with audit timestamp.
-- ---------------------------------------------------------------------------

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id              NVARCHAR(50),    -- product key/code
    cat             NVARCHAR(50),    -- category (e.g., Bikes, Components)
    subcat          NVARCHAR(50),    -- subcategory (e.g., Mountain, Road)
    maintenance     NVARCHAR(50),    -- 'Yes'/'No' (can normalize later)
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- audit
);
GO
