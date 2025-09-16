# SQL Data Warehouse (Medallion) — SQL Server

A compact, production-style data warehouse on **Microsoft SQL Server** using the **Medallion Architecture**:  
**Bronze** (raw landing) → **Silver** (standardized) → **Gold** (business-ready star schema).

---

## Introduction
This project consolidates CSV exports from **CRM** and **ERP** systems into a single SQL Server data warehouse.  
Data lands raw in **Bronze**, is cleansed and normalized in **Silver**, and is exposed for analytics in **Gold** as **dimension** and **fact** views. The result is a clean surface for BI, EDA, and analytics projects.

**Stack:** SQL Server • VS Code (SQL Server extension) • Git Bash • GitHub

---

## Scenario / Problem Statement
- The organization has operational data spread across **CRM** and **ERP** files with inconsistent formats:
  - Dates stored as integers (`yyyymmdd`)
  - Encoded attributes (e.g., gender `M/F`, marital `S/M`, country codes)
  - Product lineage encoded in keys
  - Potential duplicates on natural keys
- Goal: build a **reproducible** data warehouse that:
  - Ingests raw files as-is
  - **Cleans and standardizes** key attributes
  - Derives consistent business columns
  - Publishes a **star schema** for analytics and reporting

---

## Datasets Used
**CRM (source_crm/)**
- `cust_info.csv` — customer master (IDs, names, gender, marital status, create date)
- `prd_info.csv` — product master (ID, product key, name, cost, product line, effective dates)
- `sales_details.csv` — order lines (order number, product key, customer id, dates, sales, qty, price)

**ERP (source_erp/)**
- `CUST_AZ12.csv` — customer demographics (customer key, birthdate, gender)
- `LOC_A101.csv` — customer location (customer key, country)
- `PX_CAT_G1V2.csv` — product category metadata (category id, category, subcategory, maintenance flag)

> Files reside in the repository under `datasets/source_crm` and `datasets/source_erp`.

---

## Objectives
- **Modeling & Conventions**
  - Create `DataWarehouse` with schemas: `bronze`, `silver`, `gold`
  - Apply consistent **snake_case** naming and reserved-word hygiene
- **ETL (Skills Demonstrated)**
  - **Extract/Load:** `BULK INSERT` raw CSVs → **Bronze** with fast, idempotent loads (e.g., `TABLOCK`)
  - **Transform (Silver):**
    - Convert INT dates → `DATE`
    - Normalize **gender**, **marital_status**, and **country** values
    - Derive `cat_id` from `prd_key`; compute effective dating via `LEAD(...)-1`
    - De-duplicate customers by most recent `cst_create_date`
    - Add `dwh_create_date` audit column
  - **Publish (Gold):**
    - Views: `gold.dim_customers`, `gold.dim_products`, `gold.fact_sales`
    - Star-schema joins via natural/business keys mapped to view surrogate keys
- **Quality & Verification**
  - Silver checks: keys/whitespace/domains/date rules/math consistency
  - Gold checks: surrogate-key uniqueness and referential integrity (no null FKs)
- **Reproducibility**
  - Self-contained datasets, scripts, and clear repository structure

---

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
│  ├─ init_database.sql                 # Create DB + bronze/silver/gold schemas (destructive in dev)
│  ├─ bronze/
│  │  ├─ ddl_bronze.sql                 # Raw landing tables
│  │  └─ proc_load_bronze.sql           # BULK INSERT from datasets → Bronze
│  ├─ silver/
│  │  ├─ ddl_silver.sql                 # Standardized tables + audit column
│  │  └─ proc_load_silver.sql           # Bronze → Silver transforms
│  └─ gold/
│     └─ ddl_gold.sql                   # Gold views (dim_customers, dim_products, fact_sales)
├─ tests/
│  ├─ quality_checks_silver.sql         # Keys/domains/date rules/math checks
│  └─ quality_checks_gold.sql           # Surrogate uniqueness & join integrity
├─ .gitignore
├─ LICENSE
└─ README.md
```

---

## Conclusion

This build demonstrates end-to-end **ETL** on **SQL Server**:

- Fast, repeatable ingest from CSV to Bronze

- Robust transformations in Silver for clean, standardized datasets

- Business-ready Gold star schema for analytics and reporting

- Quality checks to validate correctness and trust

---

## Related Projects
- **SQL Exploratory Data Analysis (EDA):** https://github.com/Emadeddin-Beshtawi/sql-exploratory-data-analysis-project
- **SQL Data Analytics:** https://github.com/Emadeddin-Beshtawi/sql-data-analytics-project







