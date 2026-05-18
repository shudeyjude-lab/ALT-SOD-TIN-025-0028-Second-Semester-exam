/* Customer Segmentation: Add a column called customer_segment to a query on dw_user_analytics using the following rules:
•	‘High Value’ — customers with total revenue above ₦5,000,000.
•	‘Mid Value’ — customers with total revenue above ₦1,000,000.
•	‘Low Value’ — all other customers.
 */

SELECT 
    customer_id,
    customer_name,
    total_revenue,
    -- Segmenting customers based on financial contribution thresholds
    CASE 
        WHEN total_revenue > 5000000 THEN 'High Value'
        WHEN total_revenue > 1000000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM `data_warehouse.dw_user_analytics`
ORDER BY total_revenue DESC;