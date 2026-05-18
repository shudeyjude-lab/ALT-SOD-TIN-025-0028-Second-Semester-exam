/* Top Customers by Revenue: Return the top 10 customers ranked by total lifetime revenue, highest first. */

SELECT 
    customer_id,
    customer_name,
    email,
    country,
    total_revenue
FROM `data_warehouse.dw_user_analytics`
ORDER BY total_revenue DESC
LIMIT 10;