
/* Create a table that aggregates stg_billing to produce, per customer:
•	total_revenue — the sum of all billed amounts.
•	total_transactions — a count of all transactions.
*/

CREATE OR REPLACE TABLE `data_tel_gold.agg_user_revenue` AS
SELECT
  customer_id,
  -- Summing the cleaned amounts from the Silver layer
  SUM(amount) AS total_revenue,
  -- Counting the numberof unique successful transactions
  COUNT(transaction_id) AS total_transactions
FROM `data_tel_silver.stg_billing`
GROUP BY customer_id;