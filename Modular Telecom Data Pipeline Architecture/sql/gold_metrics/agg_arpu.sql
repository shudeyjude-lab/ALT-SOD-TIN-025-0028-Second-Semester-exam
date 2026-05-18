-----------------------------  STAGE 3 The Transformation Layer ----------------------------- 

/* Create a table that calculates ARPU per customer. ARPU is defined as total revenue divided by the number of distinct calendar months in which the customer had at least one transaction.*/

CREATE OR REPLACE TABLE `data_tel_gold.agg_arpu` AS
SELECT
  customer_id,
  -- Total revenue from our previously cleaned billing data
  SUM(amount) AS total_lifetime_revenue,
  -- Count of unique months with at least one transaction
    COUNT(DISTINCT DATE_TRUNC(transaction_timestamp, MONTH)) AS active_months_count,
    -- Calculating ARPU: Total Revenue / Active Months
    -- NULLIF prevents 'division by zero' if a customer has 0 active months
    SUM(amount) / NULLIF(COUNT(DISTINCT DATE_TRUNC(transaction_timestamp, MONTH)), 0) AS arpu
FROM `data_tel_silver.stg_billing`
GROUP BY customer_id;