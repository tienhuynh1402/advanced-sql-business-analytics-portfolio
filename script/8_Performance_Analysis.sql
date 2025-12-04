/*
===============================================================================
Preformance Analysis
===============================================================================
Purpose:
    - To track monthly sales performance and cumulative revenue trends.
    - To calculate running totals and moving averages over time.
    - To support financial forecasting and growth analysis.
SQL Functions Used:
    - DATETRUNC(), SUM(), AVG(), Window Functions (OVER, ORDER BY)
===============================================================================
*/

-- Calculate total sales per month
SELECT DATETRUNC(MONTH,order_date) AS order_date,SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH,order_date)
ORDER BY DATETRUNC(MONTH,order_date);

-- Calculate monthly sales with running total
SELECT order_date,total_sales,SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT DATETRUNC(MONTH,order_date) AS order_date,SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH,order_date)
) t
ORDER BY order_date;

-- Calculate monthly sales with running total and moving average price
SELECT order_date,
       total_sales,
       SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
       AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg_price
FROM (
    SELECT DATETRUNC(MONTH,order_date) AS order_date,
           SUM(sales_amount) AS total_sales,
           AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH,order_date)
) t
ORDER BY order_date;

/*
===============================================================================
Metrics Explanation:
    - total_sales: Revenue generated in each month.
    - running_total_sales: Cumulative revenue from start to current month.
    - moving_avg_price: Running average of monthly average prices over time.
    
Usage Notes:
    - Running totals help visualize cumulative growth trajectories.
    - Moving averages smooth out monthly fluctuations to show trends.
    - Use for year-to-date (YTD) reporting and growth rate calculations.
    - DATETRUNC truncates dates to first day of month for monthly grouping.
===============================================================================
*/


