/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - To consolidate key customer metrics and behaviors into a single view.
    - To enable customer segmentation and lifetime value analysis.
    - To support customer relationship management and targeted marketing.
Highlights:
    1. Gathers essential fields: names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
       - Total orders, sales, quantity purchased, and unique products
       - Customer lifespan (in months)
    4. Calculates valuable KPIs:
       - Recency (months since last order)
       - Average order value
       - Average monthly spend
SQL Functions Used:
    - CTE (WITH), DATEDIFF(), COUNT(), SUM(), MAX(), MIN(), CASE, String Concatenation
===============================================================================
*/

CREATE VIEW gold.report_customer AS
WITH base_query AS (
/*--------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact and dimension tables
--------------------------------------------------------------------------*/
    SELECT f.order_number,f.product_key,f.order_date,f.sales_amount,f.quantity,
           c.customer_key,c.customer_number,
           c.first_name + ' ' + c.last_name AS customer_name,
           DATEDIFF(YEAR,c.birthdate,(SELECT MAX(order_date) FROM gold.fact_sales)) AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key=c.customer_key
    WHERE order_date IS NOT NULL
),
customer_aggregation AS (
/*--------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
--------------------------------------------------------------------------*/
    SELECT customer_key,customer_number,customer_name,age,
           COUNT(DISTINCT order_number) AS total_orders,
           SUM(sales_amount) AS total_sales,
           SUM(quantity) AS purchase_quantity,
           MAX(order_date) AS last_order_date,
           DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
    FROM base_query 
    GROUP BY customer_key,customer_number,customer_name,age
)
/*--------------------------------------------------------------------------
3) Final Output: Adds segmentation, KPIs, and calculated metrics
--------------------------------------------------------------------------*/
SELECT customer_key,
       customer_number,
       customer_name,
       age,
       CASE 
           WHEN age < 20 THEN 'Under 20'
           WHEN age BETWEEN 20 AND 29 THEN '20-29'
           WHEN age BETWEEN 30 AND 39 THEN '30-39'
           WHEN age BETWEEN 40 AND 49 THEN '40-49'
           ELSE '50 and above' 
       END AS age_group,
       CASE 
           WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
           WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
           ELSE 'New'
       END AS customer_segment,
       DATEDIFF(MONTH,last_order_date,(SELECT MAX(order_date) FROM gold.fact_sales)) AS recency,
       total_orders,
       total_sales,
       purchase_quantity,
       last_order_date,
       life_span,
       CASE 
           WHEN total_orders = 0 THEN 0
           ELSE total_sales/total_orders  
       END AS avg_order_value,
       CASE 
           WHEN life_span = 0 THEN total_sales
           ELSE total_sales/life_span
       END AS average_monthly_spend
FROM customer_aggregation;

/*
===============================================================================
View Structure:
    - Customer Demographics: customer_key, customer_number, customer_name, age, age_group
    - Segmentation: customer_segment (VIP/Regular/New)
    - Transaction Metrics: total_orders, total_sales, purchase_quantity
    - Temporal Metrics: last_order_date, life_span, recency
    - KPIs: avg_order_value, average_monthly_spend
    
Usage Notes:
    - Use this view for customer dashboards and segmentation analysis.
    - Recency indicates engagement risk (high recency = potential churn).
    - Average monthly spend helps identify high-value customers over time.
    - Age groups enable demographic targeting for marketing campaigns.
    - Customer segments drive personalized retention strategies.
===============================================================================
*/