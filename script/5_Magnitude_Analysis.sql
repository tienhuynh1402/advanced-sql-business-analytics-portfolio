/*
===============================================================================
Magnitude Analysis
===============================================================================
Purpose:
    - To analyze the distribution and scale of data across key dimensions.
    - To understand customer demographics, product inventory, and sales patterns.
    - To identify concentration of business activity by geography and category.
SQL Functions Used:
    - COUNT(), SUM(), AVG(), GROUP BY, ORDER BY, Aggregations
===============================================================================
*/

-- Analyze customer distribution by country
SELECT country,COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country 
ORDER BY total_customers DESC;

-- Analyze customer distribution by gender
SELECT gender,COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender 
ORDER BY total_customers DESC;

-- Analyze product inventory by category
SELECT category,COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Calculate average product cost by category
SELECT category,AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Calculate total revenue by product category
SELECT category,SUM(sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_products p ON s.product_key=p.product_key
GROUP BY category
ORDER BY total_revenue DESC;

-- Calculate total revenue by customer
SELECT c.customer_key,first_name,last_name,SUM(sales_amount) AS total_revenue
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key=c.customer_key
GROUP BY c.customer_key,first_name,last_name
ORDER BY total_revenue DESC;

-- Analyze quantity sold distribution by country
SELECT c.country,SUM(quantity) AS total_sold_items
FROM gold.fact_sales s
LEFT JOIN gold.dim_customers c ON s.customer_key=c.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;

/*
===============================================================================
Usage Notes:
    - These queries reveal the scale and concentration of business activity.
    - Use country distribution to identify key markets and expansion opportunities.
    - Gender distribution supports demographic targeting strategies.
    - Category analysis informs inventory planning and product focus.
    - Revenue by customer identifies high-value accounts for retention programs.
    - Quantity by country shows demand patterns across geographies.
===============================================================================
*/