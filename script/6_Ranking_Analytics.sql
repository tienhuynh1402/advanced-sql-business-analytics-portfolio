/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To identify top and bottom performers across products and customers.
    - To support strategic decisions on product portfolio and customer focus.
    - To enable data-driven resource allocation and marketing prioritization.
SQL Functions Used:
    - TOP, ROW_NUMBER(), SUM(), COUNT(), DISTINCT, Window Functions (OVER)
===============================================================================
*/

-- Identify top 5 products by total revenue
SELECT TOP 5 product_name,SUM(sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key=p.product_key 
GROUP BY product_name
ORDER BY total_revenue DESC;

-- Alternative approach: Top 5 products using ROW_NUMBER ranking function
SELECT *
FROM (
    SELECT product_name,
           SUM(sales_amount) AS total_revenue,
           ROW_NUMBER() OVER (ORDER BY SUM(sales_amount) DESC) AS rank_products
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p ON s.product_key=p.product_key 
    GROUP BY product_name
) t
WHERE rank_products <= 5;

-- Identify bottom 5 worst performing products by revenue
SELECT TOP 5 product_name,SUM(sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key=p.product_key 
GROUP BY product_name
ORDER BY total_revenue ASC;

-- Find top 10 customers by total revenue generated
SELECT TOP 10 c.customer_key,first_name,last_name,SUM(sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key=c.customer_key
GROUP BY c.customer_key,first_name,last_name
ORDER BY total_revenue DESC;

-- Identify bottom 3 customers with fewest orders placed
SELECT TOP 3 c.customer_key,first_name,last_name,COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key=c.customer_key
GROUP BY c.customer_key,first_name,last_name
ORDER BY total_orders ASC;

/*
===============================================================================
Ranking Methods:
    - TOP N: Simple and efficient for basic ranking queries.
    - ROW_NUMBER(): Useful when ranking logic needs to be part of complex queries.
    - Both methods produce identical results for this analysis.
    
Usage Notes:
    - Top products drive revenue focus and inventory investment.
    - Bottom products may require promotion, repositioning, or discontinuation.
    - Top customers are candidates for VIP programs and retention efforts.
    - Low-engagement customers may benefit from reactivation campaigns.
===============================================================================
*/