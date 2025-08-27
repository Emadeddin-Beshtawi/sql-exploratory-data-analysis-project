/*
=============================================================
DataWarehouse — Create Database and Schemas (Annotated)
=============================================================
Purpose
  - Recreate a clean development database named [DataWarehouse].
  - Create three schemas for Medallion architecture: [bronze], [silver], [gold].

Scope & Behavior
  - If [DataWarehouse] exists, it is forced to SINGLE_USER (kicks out connections),
    then dropped; a fresh database is created and schemas added.

Safety Notes (DESTRUCTIVE)
  - This is DEV-ONLY: running will permanently delete the existing DataWarehouse.
  - Ensure you have backups and do not run against a shared/prod instance.

Assumptions
  - SQL Server (T-SQL), user has permissions to CREATE/DROP database and CREATE SCHEMA.
  - This script is executed via VS Code + SQL Server extension.

Change Log
  - 2025-08-23: Initial annotated version (no functional changes).
*/

-- Put session in the [master] context so the DROP/CREATE DATABASE statements work
USE master;
GO  -- Separate batch so the context change takes effect before conditional drop

-- If a database named [DataWarehouse] exists, force single-user and drop it.
-- SINGLE_USER WITH ROLLBACK IMMEDIATE will terminate other connections quickly.
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- force exclusive access
    DROP DATABASE DataWarehouse; -- destructive: removes DB and all contained objects
END;
GO  -- Ensure the drop (if any) completes before attempting to create

-- Create a fresh [DataWarehouse] database.
-- (Using default file settings; for portfolio/dev this is fine.)
CREATE DATABASE DataWarehouse;
GO  -- Complete DB creation before switching context

-- Switch context to the newly created database to create schemas
USE DataWarehouse;
GO

-- Create Medallion schemas. Fresh DB guarantees they don't exist yet.
CREATE SCHEMA bronze;  -- Raw landing / ingestion layer
GO

CREATE SCHEMA silver;  -- Cleaned, standardized, conformed layer
GO

CREATE SCHEMA gold;    -- Business-ready star schema (dims/facts, reporting)
GO
