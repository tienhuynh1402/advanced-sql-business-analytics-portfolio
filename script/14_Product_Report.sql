/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - To consolidate key product metrics and performance indicators.
    - To enable product segmentation and inventory optimization.
    - To support pricing strategy and product lifecycle management.
Highlights:
    1. Gathers essential fields: product details, pricing, and transaction data.
    2. Segments products into performance categories (High/Mid/Low Performer).
    3. Aggregates product-level metrics:
       - Total sales, orders, quantity sold, and unique customers
       - Product lifespan and recency
    4. Calculates valuable KPIs:
       - Average price and average order revenue
       - Average monthly revenue
SQL Functions Used:
    - CTE (WITH), DATEDIFF(), COUNT(), SUM(), MAX(), MIN(), AVG(), CASE
===============================================================================
*/

CREATE VIEW gold.report_product AS
WITH base_query AS (
/*--------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact and dimension tables
--------------------------------------------------------------------------*/
    SELECT f.order_number,f.order_date,f.sales_amount,f.quantity,f.customer_key,
           p.product_key,p.product_name,p.category,p.subcategory,p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key=p.product_key
    WHERE order_date IS NOT NULL
),
product_aggregation AS (
/*--------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
--------------------------------------------------------------------------*/
    SELECT product_key,product_name,category,subcategory,cost,
           SUM(sales_amount) AS total_sales,
           COUNT(order_number) AS total_orders,
           SUM(quantity) AS total_quantity_sold,
           MAX(order_date) AS last_order_date,
           COUNT(DISTINCT customer_key) AS total_customers,
           DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span,
           AVG(sales_amount/quantity) AS avg_price
    FROM base_query
    GROUP BY product_key,product_name,category,subcategory,cost
)
/*--------------------------------------------------------------------------
3) Final Output: Adds segmentation, recency, and calculated KPIs
--------------------------------------------------------------------------*/
SELECT product_key,
       product_name,
       category,
       subcategory,
       cost,
       CASE 
           WHEN total_sales > 5000 THEN 'High Performer'
           WHEN total_sales >= 1000 THEN 'Mid Range'
           ELSE 'Low Performer'
       END AS product_segment,
       life_span,
       total_sales,
       total_quantity_sold,
       total_orders,
       last_order_date,
       total_customers,
       avg_price,
       DATEDIFF(MONTH,last_order_date,(SELECT MAX(order_date) FROM gold.fact_sales)) AS recency,
       CASE 
           WHEN total_orders = 0 THEN 0
           ELSE total_sales/total_orders
       END AS average_order_revenue,
       CASE 
           WHEN life_span = 0 THEN total_sales
           ELSE total_sales/life_span
       END AS average_monthly_revenue
FROM product_aggregation;

/*
===============================================================================
View Structure:
    - Product Details: product_key, product_name, category, subcategory, cost
    - Segmentation: product_segment (High/Mid/Low Performer)
    - Transaction Metrics: total_sales, total_orders, total_quantity_sold, total_customers
    - Temporal Metrics: last_order_date, life_span, recency
    - KPIs: avg_price, average_order_revenue, average_monthly_revenue
    
Usage Notes:
    - Use this view for product performance dashboards and inventory analysis.
    - High performers drive revenue and should have priority stock levels.
    - Low performers may need promotional pricing or discontinuation.
    - Recency indicates product activity (high recency = inactive products).
    - Average monthly revenue helps forecast future sales by product.
===============================================================================
*/