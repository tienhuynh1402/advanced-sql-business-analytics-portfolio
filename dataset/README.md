# Dataset Setup Guide

## Overview

This analysis uses a SQL Server database backup (`DataWarehouseAnalytics.bak`) containing pre-processed data from a dimensional data warehouse. The dataset represents the **Gold Layer** (analytical layer) created in the companion project: [sql-data-warehouse-project](https://github.com/tienhuynh1402/sql-data-warehouse-project).

**Data Source:** CycleHub e-commerce transactions (2010-2014)  
**Database Size:** 9.817 KB  
**Schema:** Gold layer dimensional model (star schema)  
**Tables:** `gold.fact_sales`, `gold.dim_customers`, `gold.dim_products`

---

## Prerequisites

- **SQL Server 2019+** (Express, Developer, or Enterprise)
- **SQL Server Management Studio (SSMS)** 18.0 or higher
- **Minimum 50 MB disk space**
- **Windows/Linux/Docker** environment

---

## Setup Instructions

### Option 1: Restore via SSMS (Recommended)

1. **Download the backup file:**
```
   DataWarehouseAnalytics.bak
```

2. **Open SQL Server Management Studio (SSMS)**
   - Connect to your SQL Server instance

3. **Restore Database:**
   - Right-click **Databases** → **Restore Database**
   - Select **Device** → Click **...** button
   - Click **Add** → Navigate to `DataWarehouseAnalytics.bak`
   - Click **OK**
   - Verify database name: `DataWarehouseAnalytics`
   - Click **OK** to restore

4. **Verify Restoration:**
```sql
   USE DataWarehouseAnalytics;
   SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'gold';
```

### Option 2: Restore via T-SQL
```sql
USE master;
GO

RESTORE DATABASE DataWarehouseAnalytics
FROM DISK = 'C:\Path\To\DataWarehouseAnalytics.bak'
WITH 
    MOVE 'DataWarehouseAnalytics' TO 'C:\SQLData\DataWarehouseAnalytics.mdf',
    MOVE 'DataWarehouseAnalytics_log' TO 'C:\SQLData\DataWarehouseAnalytics_log.ldf',
    REPLACE;
GO
```

**Note:** Adjust file paths based on your SQL Server data directory.


## Database Structure

### Schema: `gold` (Analytical Layer)

#### Fact Table: `gold.fact_sales`
Transaction-level sales data with foreign keys to dimension tables.

**Key Columns:**
- `order_number` - Unique order identifier
- `order_date` - Transaction date
- `sales_amount` - Revenue per transaction
- `quantity` - Items sold
- `price` - Unit price
- `customer_key` - FK to dim_customers
- `product_key` - FK to dim_products

#### Dimension Table: `gold.dim_customers`
Customer master data with demographics.

**Key Columns:**
- `customer_key` - Primary key
- `customer_number` - Business key
- `first_name`, `last_name` - Customer name
- `country` - Geographic location
- `birthdate` - Date of birth
- `gender` - Gender classification

#### Dimension Table: `gold.dim_products`
Product catalog with pricing and categorization.

**Key Columns:**
- `product_key` - Primary key
- `product_name` - Product name
- `category` - Product category (Bikes, Accessories, Clothing)
- `subcategory` - Detailed classification
- `cost` - Product cost

---

## Data Warehouse Project Attribution

This dataset is the **analytical output** from the ETL pipeline built in:

**Repository:** [sql-data-warehouse-project](https://github.com/tienhuynh1402/sql-data-warehouse-project)   
**ETL Architecture:** Medallion (Bronze → Silver → Gold)  
**Purpose:** Data Engineering Bootcamp capstone project

The original project handles:
- Data extraction from CRM/ERP source systems
- Data cleansing and transformation (Bronze → Silver layers)
- Dimensional modeling and aggregation (Gold layer)
- This `.bak` file represents the final Gold layer output

**Analysis Scope:** This repository focuses exclusively on SQL analytics and business intelligence **using** the pre-built Gold layer, not on data engineering or ETL processes.

---

## Quick Start Validation

After restoration, run this validation query:
```sql
USE DataWarehouseAnalytics;

-- Validate table structure
SELECT TABLE_SCHEMA,TABLE_NAME,TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'gold'
ORDER BY TABLE_NAME;

-- Check record counts
SELECT 'fact_sales' AS table_name, COUNT(*) AS record_count FROM gold.fact_sales
UNION ALL
SELECT 'dim_customers', COUNT(*) FROM gold.dim_customers
UNION ALL
SELECT 'dim_products', COUNT(*) FROM gold.dim_products;

-- Sample data
SELECT TOP 5 * FROM gold.fact_sales;
SELECT TOP 5 * FROM gold.dim_customers;
SELECT TOP 5 * FROM gold.dim_products;
```

**Expected Results:**
- 3 tables in `gold` schema
- ~60,000 sales records
- ~18,000 customers
- ~295 products


---

## Next Steps

Once setup is complete:

1. Run `1_Database_exploration.sql` to verify structure
2. Execute analyses in numerical order (1-14)
3. Review outputs in Excel for visualization
4. Explore advanced analyses: RFM segmentation, cohort retention

---

## Related Resources

- **Data Warehouse Project:** [sql-data-warehouse-project](https://github.com/yourusername/sql-data-warehouse-project)
- **SSMS Download:** [Download SSMS](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

---

**Questions?** Open an issue in this repository.
