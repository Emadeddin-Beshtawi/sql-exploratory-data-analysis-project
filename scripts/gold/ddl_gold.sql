/*
===============================================================================
Gold Layer — Star Schema Views (Annotated)
===============================================================================
Purpose
  - Expose business-ready, analytics-focused entities as views:
      • gold.dim_customers
      • gold.dim_products
      • gold.fact_sales
  - Views compose the Silver layer and present a clean star schema surface.

Notes & Tradeoffs
  - Surrogate keys generated via ROW_NUMBER() in a view are not stable across
    refreshes. For production, consider materialized tables with IDENTITY keys.
  - Filters: dim_products excludes historical rows (prd_end_dt IS NULL).

Usage
  - Run after Silver load to (re)create views for reporting.
===============================================================================
*/
USE DataWarehouse;
GO
-- =============================================================================
-- DIMENSION VIEW: gold.dim_customers
-- Enrich CRM customers with ERP demographics and location.
-- Primary gender source = CRM; fallback = ERP if CRM is 'n/a'.
-- =============================================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,   -- surrogate (view-scoped, non-stable)
    ci.cst_id                          AS customer_id,        -- natural id from CRM
    ci.cst_key                         AS customer_number,    -- business key
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr            -- CRM primary
        ELSE COALESCE(ca.gen, 'n/a')                          -- ERP fallback
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info  AS ci
LEFT JOIN silver.erp_cust_az12 AS ca
    ON ci.cst_key = ca.cid                                     -- link via standardized cid
LEFT JOIN silver.erp_loc_a101 AS la
    ON ci.cst_key = la.cid;                                    -- location by cid
GO

-- =============================================================================
-- DIMENSION VIEW: gold.dim_products
-- Current (non-historical) products enriched with category metadata.
-- Filters to rows where prd_end_dt IS NULL (active).
-- =============================================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- surrogate (view-scoped)
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_px_cat_g1v2 AS pc
    ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;                                   -- keep current snapshot only
GO

-- =============================================================================
-- FACT VIEW: gold.fact_sales
-- Transaction grain: one row per order line (from CRM sales details).
-- Joins to dimensions via business keys → view-generated surrogate keys.
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,           -- order id
    pr.product_key  AS product_key,            -- surrogate from gold.dim_products view
    cu.customer_key AS customer_key,           -- surrogate from gold.dim_customers view
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details AS sd
LEFT JOIN gold.dim_products   AS pr
    ON sd.sls_prd_key = pr.product_number      -- bridge via product business key
LEFT JOIN gold.dim_customers  AS cu
    ON sd.sls_cust_id = cu.customer_id;        -- bridge via customer id
GO
