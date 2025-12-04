/*
===============================================================================
Cohort Retention Analysis
===============================================================================
Purpose:
    - To analyze customer retention patterns over time by first purchase cohort.
    - To measure how many customers return to make repeat purchases each month.
    - To identify the most valuable customer acquisition periods.
SQL Functions Used:
    - CTE (WITH), MIN(), FORMAT(), DATEDIFF(), COUNT(), PIVOT, DISTINCT
===============================================================================
*/

-- Extract distinct customer orders with purchase dates
WITH list_order AS (
    SELECT DISTINCT customer_key,order_date
    FROM gold.fact_sales
),
-- Identify first purchase date for each customer
list_first_purchase AS (
    SELECT customer_key,
           MIN(order_date) AS first_purchase_date,
           FORMAT(MIN(order_date),'yyyy-MM') AS first_purchase_month
    FROM list_order
    GROUP BY customer_key
),
-- Calculate months elapsed since first purchase (cohort index)
cohort_index AS (
    SELECT DISTINCT o.customer_key,
           first_purchase_month,
           DATEDIFF(MONTH,first_purchase_date,order_date) AS cohort_index
    FROM list_order AS o 
    LEFT JOIN list_first_purchase AS fp ON o.customer_key=fp.customer_key
)
-- Pivot data to show customer counts by cohort month and retention period
SELECT first_purchase_month,[0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
INTO #cohort_pivot
FROM cohort_index
PIVOT (
    COUNT(customer_key) 
    FOR cohort_index IN ([0],[1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]) 
) AS pvt 
WHERE first_purchase_month BETWEEN '2013-01' AND '2013-12'
ORDER BY first_purchase_month;

-- Display raw customer counts by cohort
SELECT * 
FROM #cohort_pivot
ORDER BY first_purchase_month;

-- Convert to retention percentages (percentage of original cohort returning each month)
SELECT first_purchase_month,
       FORMAT(1.0*[0]/[0],'P') AS [0],
       FORMAT(1.0*[1]/[0],'P') AS [1],
       FORMAT(1.0*[2]/[0],'P') AS [2],
       FORMAT(1.0*[3]/[0],'P') AS [3],
       FORMAT(1.0*[4]/[0],'P') AS [4],
       FORMAT(1.0*[5]/[0],'P') AS [5],
       FORMAT(1.0*[6]/[0],'P') AS [6],
       FORMAT(1.0*[7]/[0],'P') AS [7],
       FORMAT(1.0*[8]/[0],'P') AS [8],
       FORMAT(1.0*[9]/[0],'P') AS [9],
       FORMAT(1.0*[10]/[0],'P') AS [10],
       FORMAT(1.0*[11]/[0],'P') AS [11],
       FORMAT(1.0*[12]/[0],'P') AS [12]
FROM #cohort_pivot
ORDER BY first_purchase_month;

/*
===============================================================================
Cohort Analysis Interpretation:
    - Column [0]: Initial cohort size (100% by definition).
    - Columns [1]-[12]: Percentage of original cohort returning after N months.
    - Example: If [3] shows 45%, it means 45% of customers returned 3 months after first purchase.
    
Usage Notes:
    - Adjust the date range (2013-01 to 2013-12) to analyze different cohort periods.
    - Extend cohort_index columns ([13],[14]...) for longer retention tracking.
    - Low retention rates indicate need for engagement/reactivation campaigns.
    - High retention rates identify successful acquisition periods to replicate.
===============================================================================
*/