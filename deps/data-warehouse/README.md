# SQL Data Warehouse (Medallion) — Portfolio Project

> **Layers:** Bronze → Silver → Gold &nbsp;•&nbsp; **Engine:** Microsoft SQL Server &nbsp;•&nbsp; **Tools:** VS Code (SQL Server extension), Git Bash, and GitHub

This repository showcases a compact, production-style **Medallion Architecture** on SQL Server. Raw CSVs land in **Bronze**, are cleansed/standardized in **Silver**, and exposed as business-ready **Gold** models (star schema) for analytics. Every script is annotated line-by-line for clarity, and quality checks are included so reviewers can verify results quickly.

## Table of Contents
- [Project Goals](#project-goals)
- [Data & Naming Conventions](#data--naming-conventions)
- [Repository Structure](#repository-structure)
- [Gold (Star Schema) Surface](#gold-star-schema-surface)
- [Notes & Decisions](#notes--decisions)
- [License](#license)

## Project Goals
- Demonstrate a clean **Bronze → Silver → Gold** pipeline on Microsoft SQL Server.
- Keep **DDL/ETL readable** with line-by-line annotations in every script.
- Provide **verifiable checks** for Silver and Gold so reviewers can trust results.
- Make it **portfolio-friendly**: tidy repo layout, meaningful commits, and a v0.1.0 tag.
- Ensure **easy local reproduction** using the included CSV datasets and VS Code.

## Data & Naming Conventions

**Style**
- `snake_case`, English names, avoid SQL reserved words.

**Schemas**
- `bronze` (raw), `silver` (standardized), `gold` (business-ready/star).

**Tables / Views**
- **Bronze & Silver:** `<source>_<entity>` (e.g., `crm_cust_info`, `erp_px_cat_g1v2`), mirroring source names.
- **Gold:** `dim_*` for dimensions, `fact_*` for facts (e.g., `dim_customers`, `fact_sales`).

**Columns**
- Prefer descriptive, `snake_case` column names.
- **Surrogate keys (Gold dims):** `<entity>_key` (e.g., `customer_key`, `product_key`).
- **Technical columns:** prefix with `dwh_` (e.g., `dwh_create_date` in Silver).

**Data Types (guidance)**
- Keep raw types in Bronze; normalize in Silver (e.g., INT `yyyymmdd` → `DATE`).
- Monetary fields may remain `INT` in Silver and be promoted to `DECIMAL(18,2)` in Gold if needed.

**Stored Procedures**
- Loading procs follow `load_<layer>` (e.g., `bronze.load_bronze`, `silver.load_silver`).

## Repository Structure

```text
sql-data-warehouse-project/
├─ datasets/
│  ├─ source_crm/
│  │  ├─ cust_info.csv
│  │  ├─ prd_info.csv
│  │  └─ sales_details.csv
│  └─ source_erp/
│     ├─ CUST_AZ12.csv
│     ├─ LOC_A101.csv
│     └─ PX_CAT_G1V2.csv
├─ scripts/
│  ├─ init_database.sql
│  ├─ bronze/
│  │  ├─ ddl_bronze.sql
│  │  └─ proc_load_bronze.sql
│  ├─ silver/
│  │  ├─ ddl_silver.sql
│  │  └─ proc_load_silver.sql
│  └─ gold/
│     └─ ddl_gold.sql
├─ tests/
│  ├─ quality_checks_silver.sql
│  └─ quality_checks_gold.sql
├─ .gitignore
├─ LICENSE
└─ README.md 
```
## Gold (Star Schema) Surface

**Dimensions**
- `gold.dim_customers`  
  `(customer_key, customer_id, customer_number, first_name, last_name, country, marital_status, gender, birthdate, create_date)`
- `gold.dim_products`  
  `(product_key, product_id, product_number, product_name, category_id, category, subcategory, maintenance, cost, product_line, start_date)`

**Fact**
- `gold.fact_sales`  
  `(order_number, product_key, customer_key, order_date, shipping_date, due_date, sales_amount, quantity, price)`

## Notes & Decisions
- **Medallion layers:** Bronze (raw CSV), Silver (standardized), Gold (business-ready views).
- **Gold as views:** Surrogate keys use `ROW_NUMBER()` for demo speed; in production prefer materialized tables with `IDENTITY` keys.
- **Data types:** Monetary values remain `INT` in Bronze/Silver; can be promoted to `DECIMAL(18,2)` in Gold if required.
- **Customer de-dup:** Silver keeps the most recent record per `cst_id` (ties broken by `cst_create_date`).
- **Product lineage:** `cat_id` derived from `prd_key`; Gold filters to **current** products (`prd_end_dt IS NULL`).
- **Audit column:** Silver tables include `dwh_create_date` for basic lineage.
- **Tools:** VS Code (SQL Server extension), Git Bash, and GitHub.

## License
Released under the **MIT License** — see [LICENSE](LICENSE) for details.

