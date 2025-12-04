/*
===============================================================================
RFM Segmentation Analysis
===============================================================================
Purpose:
    - To segment customers based on Recency, Frequency, and Monetary value.
    - To identify customer behavior patterns for targeted marketing campaigns.
    - To support customer retention and reactivation strategies.
SQL Functions Used:
    - NTILE(), DATEDIFF(), COUNT(), SUM(), MAX(), CONCAT(), CASE, PIVOT
===============================================================================
*/

-- ═════════════════════════════════════════════════════════════════════════
-- PART 1: CREATE RFM SEGMENTATION VIEW
-- ═════════════════════════════════════════════════════════════════════════

CREATE VIEW gold.rfm_2013 AS
WITH customer_sales AS (
/*--------------------------------------------------------------------------
1) Customer Metrics: Calculates RFM metrics for each customer
--------------------------------------------------------------------------*/
    SELECT customer_key,
           COUNT(DISTINCT order_number) AS frequency,
           SUM(sales_amount) AS monetary,
           DATEDIFF(MONTH,MAX(order_date),(SELECT MAX(order_date) FROM gold.fact_sales)) AS recency
    FROM gold.fact_sales
    GROUP BY customer_key
),
rfm_scoring AS (
/*--------------------------------------------------------------------------
2) RFM Scoring: Assigns quartile scores (1-4) for each RFM dimension
--------------------------------------------------------------------------*/
    SELECT customer_key,
           NTILE(4) OVER (ORDER BY recency DESC) AS rfm_recency,
           NTILE(4) OVER (ORDER BY monetary) AS rfm_monetary,
           NTILE(4) OVER (ORDER BY frequency) AS rfm_frequency 
    FROM customer_sales
),
rfm_final AS (
/*--------------------------------------------------------------------------
3) Score Concatenation: Combines individual scores into single RFM score
--------------------------------------------------------------------------*/
    SELECT customer_key,CONCAT(rfm_recency,rfm_frequency,rfm_monetary) AS rfm_score
    FROM rfm_scoring
)
/*--------------------------------------------------------------------------
4) Customer Segmentation: Classifies customers into business segments
--------------------------------------------------------------------------*/
SELECT customer_key,rfm_score,
       CASE 
           WHEN rfm_score LIKE '1__' THEN 'Lost Customer'
           WHEN rfm_score LIKE '[3,4][3,4][1,2]' THEN 'Promising'
           WHEN rfm_score LIKE '[3,4][3,4][3,4]' THEN 'Loyal'
           WHEN rfm_score LIKE '[3,4][1,2]%' THEN 'New Customer'
           WHEN rfm_score LIKE '[2,3,4][1,2][3,4]' THEN 'Big Spenders'
           WHEN rfm_score LIKE '2__' THEN 'Potential Churns'
           ELSE 'Others'
       END AS segment
FROM rfm_final;


-- ═════════════════════════════════════════════════════════════════════════
-- PART 2: RFM DISTRIBUTION ANALYSIS
-- ═════════════════════════════════════════════════════════════════════════

-- Generate RFM distribution matrix (unpivoted format)
SELECT LEFT(RFM_Score,1) AS Recency,
       SUBSTRING(RFM_Score,2,1) AS Frequency,
       COUNT(*) AS Customer_Count
FROM gold.rfm_2013
GROUP BY LEFT(RFM_Score,1),SUBSTRING(RFM_Score,2,1)
ORDER BY Recency DESC,Frequency;

-- Generate RFM distribution heatmap (pivoted format for Excel visualization)
SELECT Recency,
       [1] AS Frequency_1,
       [2] AS Frequency_2,
       [3] AS Frequency_3,
       [4] AS Frequency_4
FROM (
    SELECT LEFT(RFM_Score,1) AS Recency,
           SUBSTRING(RFM_Score,2,1) AS Frequency,
           Customer_Key
    FROM gold.rfm_2013
) AS SourceData
PIVOT (
    COUNT(Customer_Key)
    FOR Frequency IN ([1],[2],[3],[4])
) AS PivotTable
ORDER BY Recency DESC;


-- ═════════════════════════════════════════════════════════════════════════
-- PART 3: SEGMENT PERFORMANCE ANALYSIS
-- ═════════════════════════════════════════════════════════════════════════

-- Calculate segment distribution (simple counts)
SELECT Segment,COUNT(*) AS Customer_Count
FROM gold.rfm_2013
GROUP BY Segment
ORDER BY Customer_Count DESC;

-- Calculate segment distribution with percentages
SELECT Segment,
       COUNT(*) AS Customer_Count,
       FORMAT(ROUND(CAST(COUNT(*) AS FLOAT)/SUM(COUNT(*)) OVER (),2),'P') AS Percentage
FROM gold.rfm_2013
GROUP BY Segment
ORDER BY Customer_Count DESC;

-- Calculate revenue metrics by segment
SELECT r.Segment,
       COUNT(r.Customer_Key) AS Customer_Count,
       SUM(c.total_sales) AS Total_Revenue,
       ROUND(AVG(c.total_sales),2) AS Avg_Customer_Value
FROM gold.rfm_2013 r
LEFT JOIN gold.report_customer c ON r.Customer_Key=c.customer_key
GROUP BY r.Segment
ORDER BY Total_Revenue DESC;


/*
===============================================================================
Segment Definitions:
    - Lost Customer: Haven't purchased recently (low recency score of 1).
    - Promising: Active and frequent but lower spending (high R/F, low M).
    - Loyal: High scores across all dimensions (best customers).
    - New Customer: Recent purchase but low frequency (high R, low F).
    - Big Spenders: High monetary value regardless of frequency.
    - Potential Churns: Showing signs of disengagement (recency score of 2).
    
RFM Score Structure:
    - First digit: Recency (1=oldest, 4=most recent)
    - Second digit: Frequency (1=least orders, 4=most orders)
    - Third digit: Monetary (1=lowest spending, 4=highest spending)
    
Usage Notes:
    - NTILE(4) divides customers into quartiles: 1 (lowest) to 4 (highest).
    - Recency is sorted DESC so recent customers get higher scores.
    - Adjust segment patterns based on business-specific customer behavior.
    - Use pivoted matrix for heatmap visualization in Excel.
    - Focus reactivation efforts on Lost Customers and Potential Churns.
    - Protect Loyal segment with VIP programs and personalized service.
===============================================================================
*/