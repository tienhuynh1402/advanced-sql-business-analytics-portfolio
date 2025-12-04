/*
===============================================================================
Database Structure Exploration
===============================================================================
Purpose:
    - To discover all database objects (tables, views) across schemas.
    - To examine column definitions and data types for specific tables.
    - To support initial data warehouse analysis and documentation.
SQL Objects Used:
    - INFORMATION_SCHEMA.TABLES
    - INFORMATION_SCHEMA.COLUMNS
===============================================================================
*/

-- Retrieve all database objects including tables and views across all schemas
SELECT TABLE_CATALOG,TABLE_SCHEMA,TABLE_NAME,TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA,TABLE_NAME;

-- Examine detailed column structure for the all the tables
SELECT TABLE_SCHEMA,TABLE_NAME,COLUMN_NAME,ORDINAL_POSITION,DATA_TYPE,CHARACTER_MAXIMUM_LENGTH,IS_NULLABLE,COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
ORDER BY ORDINAL_POSITION;