/* Churn Risk Detection: Add a column called churn_risk. Flag a customer as ‘High Risk’ if they have fewer than 5 total sessions AND less than ₦1,000 in total revenue. All other customers should be labelled ‘Active’. */

SELECT 
    customer_id,
    customer_name,
    total_sessions,
    total_revenue,
    -- Labeling churn risk based on combined low usage and low spend
    CASE 
        WHEN total_sessions < 5 AND total_revenue < 1000 THEN 'High Risk'
        ELSE 'Active'
    END AS churn_risk
FROM `data_warehouse.dw_user_analytics`
ORDER BY total_sessions ASC, total_revenue ASC;

SELECT 
    customer_id,
    customer_name,
    total_sessions,
    total_revenue,
    -- Modifying the rule to protect new users (e.g., registered within the last 14 days)
    CASE 
        WHEN DATE_DIFF(CURRENT_TIMESTAMP(), created_at, DAY) <= 14 THEN 'New Account'
        WHEN total_sessions < 5 AND total_revenue < 1000 THEN 'High Risk'
        ELSE 'Active'
    END AS churn_risk
FROM `data_warehouse.dw_user_analytics`
ORDER BY churn_risk DESC;