/*
===============================================================================
Gold Layer — Quality Checks (Annotated)
===============================================================================
Purpose
  - Validate star schema integrity and analytical readiness:
      • Uniqueness of surrogate keys in dimension views
      • Referential integrity between fact and dimensions
      • End-to-end joinability for reporting

Notes
  - Keys in these DIM views come from ROW_NUMBER() → unique at query time,
    but not stable across refreshes (acceptable for portfolio/demo).
  - Any returned rows indicate issues to investigate.

Usage
  - Run after creating gold views and loading Silver.
===============================================================================
*/
USE DataWarehouse;
GO
-- ====================================================================
-- DIM: gold.dim_customers
-- Check uniqueness of surrogate key [customer_key].
-- Expectation: No rows (each key should appear exactly once).
-- ====================================================================
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- DIM: gold.dim_products
-- Check uniqueness of surrogate key [product_key].
-- Expectation: No rows (each key should appear exactly once).
-- ====================================================================
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- FACT: gold.fact_sales
-- Validate referential integrity (left joins to dims).
-- Expectation: No rows (all fact rows resolve to customer & product).
-- ====================================================================
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
  ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
  ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
