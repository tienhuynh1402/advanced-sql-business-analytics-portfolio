/*
===============================================================================
Part to Whole Analyis
===============================================================================
Purpose:
    - To identify which product categories drive the most revenue.
    - To calculate each category's percentage contribution to total sales.
    - To support product portfolio optimization and inventory decisions.
SQL Functions Used:
    - CTE (WITH), SUM(), FORMAT(), CAST(), Window Functions (OVER)
===============================================================================
*/

-- Calculate total revenue by product category with percentage contribution
WITH category_sales AS (
    SELECT category,SUM(sales_amount) AS total_revenue
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key=p.product_key
    GROUP BY category
)
SELECT category,
       total_revenue,
       SUM(total_revenue) OVER () AS overall_sales,
       FORMAT(CAST(total_revenue AS FLOAT)/SUM(total_revenue) OVER (),'P') AS percentage_of_total
FROM category_sales
ORDER BY total_revenue DESC;

/*
===============================================================================
Usage Notes:
    - Categories are ranked by revenue contribution (highest to lowest).
    - Percentage_of_total shows each category's share of overall sales.
    - Use results to identify top-performing categories for marketing focus.
    - Low-performing categories may require promotion or discontinuation.
===============================================================================
*/
