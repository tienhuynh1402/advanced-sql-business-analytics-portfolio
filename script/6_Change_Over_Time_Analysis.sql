/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To analyze sales performance trends across different time periods.
    - To track revenue, quantity, and customer engagement over time.
    - To support trend identification and forecasting.
SQL Functions Used:
    - YEAR(), MONTH(), DATETRUNC(), FORMAT(), SUM(), COUNT(), DISTINCT
===============================================================================
*/

-- Analyze sales performance by year and month (separate columns)
SELECT YEAR(order_date) AS order_year,
       MONTH(order_date) AS order_month,
       SUM(sales_amount) AS total_sales,
       SUM(quantity) AS total_quantity,
       COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date),MONTH(order_date)
ORDER BY YEAR(order_date),MONTH(order_date);

-- Analyze sales performance by month (truncated to first day of month)
SELECT DATETRUNC(MONTH,order_date) AS order_date,
       SUM(sales_amount) AS total_sales,
       SUM(quantity) AS total_quantity,
       COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);

-- Analyze sales performance by year (annual aggregation)
SELECT DATETRUNC(YEAR,order_date) AS order_date,
       SUM(sales_amount) AS total_sales,
       SUM(quantity) AS total_quantity,
       COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR,order_date)
ORDER BY DATETRUNC(YEAR,order_date);

-- Analyze sales performance by month with formatted display (yyyy-MMM)
SELECT FORMAT(order_date,'yyyy-MMM') AS order_date,
       SUM(sales_amount) AS total_sales,
       SUM(quantity) AS total_quantity,
       COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date,'yyyy-MMM')
ORDER BY FORMAT(order_date,'yyyy-MMM');

/*
===============================================================================
Analysis Levels:
    - Query 1: Year and month as separate numeric columns for detailed analysis.
    - Query 2: Monthly trends using date truncation for time-series visualization.
    - Query 3: Annual trends for high-level year-over-year comparisons.
    - Query 4: Monthly trends with readable format (e.g., 2024-Jan) for reports.
    
Usage Notes:
    - Choose the appropriate granularity based on reporting requirements.
    - Use Query 1 for pivot tables and cross-tabulation.
    - Use Query 2/4 for time-series charts and dashboards.
    - Use Query 3 for annual performance reviews and strategic planning.
===============================================================================
*/