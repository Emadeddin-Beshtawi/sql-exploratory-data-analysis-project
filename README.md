# SQL Exploratory Data Analysis (EDA) — SQL Server

Exploratory SQL project built **on top of** a Medallion data warehouse (Bronze/Silver/Gold).  
This repo contains six focused **T-SQL** scripts for exploring the database, dimensions, date ranges, measures, magnitudes, and rankings.  
The underlying DW is vendored at **`deps/data-warehouse`** (tag **v1.0.0**) so the project is self-contained.

## How to Run

1. Open the SQL scripts in `scripts/` with **VS Code → SQL Server** extension.
2. Ensure the active database is **`DataWarehouse`** (from the vendored DW).
3. Run scripts **in any order** (they’re exploratory), but a common sequence is:
   1) `01_database_exploration.sql`
   2) `02_dimensions_exploration.sql`
   3) `03_date_range_exploration.sql`
   4) `04_measures_exploration.sql`
   5) `05_magnitude_analysis.sql`
   6) `06_ranking_analysis.sql`

## Scripts

- **01_database_exploration.sql** — database & schema overview, object counts, sizes.
- **02_dimensions_exploration.sql** — explore dimensions and keys.
- **03_date_range_exploration.sql** — time coverage, missing dates, seasonality windows.
- **04_measures_exploration.sql** — inspect KPIs/measures (sales, price, quantity).
- **05_magnitude_analysis.sql** — outliers, percentiles, heavy-tail checks.
- **06_ranking_analysis.sql** — top-N products/customers, Pareto (80/20) cuts.
