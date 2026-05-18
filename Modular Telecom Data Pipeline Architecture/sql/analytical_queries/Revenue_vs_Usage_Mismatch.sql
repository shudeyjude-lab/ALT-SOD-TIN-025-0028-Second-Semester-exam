/* Revenue vs. Usage Mismatch: Write a query that returns customers who have consumed more than 10,000 MB of data but have generated less than ₦500 in revenue. These users may be on outdated or under-priced legacy plans.
 */

SELECT 
    customer_id,
    customer_name,
    email,
    total_data_used_mb,
    total_revenue,
    -- Calculating exactly how many megabytes they consume per Naira spent
    ROUND(total_data_used_mb / NULLIF(total_revenue, 0), 2) AS mb_per_naira
FROM `data_warehouse.dw_user_analytics`
WHERE total_data_used_mb > 10000 
  AND total_revenue < 500
ORDER BY total_data_used_mb DESC;