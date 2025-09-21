# SQL Exploratory Data Analysis (EDA) — SQL Server

Exploratory SQL project built on top of a **Medallion** data warehouse (Bronze → Silver → Gold) in SQL Server.  
Focus: quick, trustworthy insights with small, targeted T-SQL scripts.

---

## Introduction
This project performs **exploratory data analysis (EDA)** directly against a SQL Server warehouse.  
It uses standardized **Silver** tables and business-ready **Gold** views to answer practical questions about customers, products, dates, and sales behavior.

**Stack:** SQL Server • VS Code (SQL Server extension) • Git Bash • GitHub

---

## Scenario / Problem Statement
Analysts need to explore data **without exporting to spreadsheets or Python/R**.  
However, the source systems are fragmented (CRM and ERP), and data quality varies.  
This EDA project demonstrates how to:
- Explore structure and health of the database quickly
- Understand dimensions and date coverage
- Inspect core measures and distributions
- Run simple rankings and spot checks entirely in SQL

---

## Datasets Used
The underlying datasets are provided by the vendored **Data Warehouse**:

**CRM (source_crm/)**
- `cust_info.csv` — customer master
- `prd_info.csv` — product master
- `sales_details.csv` — sales order lines

**ERP (source_erp/)**
- `CUST_AZ12.csv` — customer demographics
- `LOC_A101.csv` — customer country
- `PX_CAT_G1V2.csv` — product category metadata

> These are available in this repo via `https://github.com/Emadeddin-Beshtawi/sql-data-warehouse-project`

---

## Objectives
- Run **EDA queries** directly in SQL over **cleaned** data
- Use **Gold** views and **Silver** tables for reliable results
- Keep analysis modular: each script targets a specific theme
- Showcase SQL-native exploration (no external notebooks needed)

## ETL Skill Highlight (inherited from DW)
- The warehouse performs **BULK INSERT** (Extract/Load) to **Bronze**
- Cleansing & standardization in **Silver** (dates, gender/marital/country, product lineage, de-dupe)
- Business-ready **Gold** (dimensions/fact) enabling robust EDA without re-cleaning

---

## Repository Structure
```text
sql-exploratory-data-analysis-project/
├─ scripts/
│  ├─ 01_database_exploration.sql
│  ├─ 02_dimensions_exploration.sql
│  ├─ 03_date_range_exploration.sql
│  ├─ 04_measures_exploration.sql
│  ├─ 05_magnitude_analysis.sql
│  └─ 06_ranking_analysis.sql
├─ deps/
│  └─ data-warehouse/                # vendored DW (tag v1.0.1)
├─ .gitignore
├─ LICENSE
└─ README.md
```
---

## Conclusion

This **EDA** repo demonstrates SQL-only analysis on a clean warehouse surface:

- Start fast with database/dimension/date exploration

- Validate measures and distributions

- Produce quick top-N rankings and sanity checks

The approach scales because ETL work is centralized in the DW; analysts focus on questions, not cleanup.

---

## Related Projects

- SQL Data Warehouse (Medallion): https://github.com/Emadeddin-Beshtawi/sql-data-warehouse-project

- SQL Data Analytics: https://github.com/Emadeddin-Beshtawi/sql-data-analytics-project