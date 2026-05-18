/* Create a table that shows each customer’s revenue broken down by calendar month. The month column should be the first day of the month (not the full timestamp).*/

CREATE OR REPLACE TABLE `data_tel_gold.agg_monthly_revenue` AS
SELECT
  customer_id,
  -- Truncating to the first day of the month (e.g., 2023-01-15 -> 2023-01-01 )
  DATE_TRUNC(transaction_timestamp, MONTH) AS revenue_month,
  -- Aggregating revenue and transaction volume for that specific month
  SUM(amount) AS monthly_revenue,

FROM `data_tel_silver.stg_billing`
GROUP BY customer_id, revenue_month;