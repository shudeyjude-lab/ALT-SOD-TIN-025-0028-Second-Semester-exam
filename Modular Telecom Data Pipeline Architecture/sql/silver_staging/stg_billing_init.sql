-----------------------------  STAGE 2 The Staging Layer ----------------------------- 

/*Create a staging table from src_billing_transactions that:
•	Removes duplicate transaction_ids, keeping only the most recent record where duplicates exist.
•	Replaces any NULL amounts with zero.
•	Casts transaction_date from its text representation to a proper timestamp type.
*/

CREATE OR REPLACE TABLE `data_tel_silver.stg_billing` AS
WITH ranked_transactions AS (
  SELECT
    transaction_id,
    customer_id,
    -- Replacing NULL amounts with 0
    COALESCE(amount, 0) AS amount,
    currency,
    -- Casting the text date to a proper Timestamp
    CAST(transaction_date AS TIMESTAMP) AS transaction_timestamp,
    -- Assigning a rank to duplicates based on the most recent date
    ROW_NUMBER() OVER (
      PARTITION BY transaction_id
      ORDER BY transaction_date DESC
    ) AS record_rank
  FROM `data_tel_bronze.src_billing_transactions`
)
SELECT
  transaction_id,
  customer_id,
  amount,
  currency,
  transaction_timestamp
FROM ranked_transactions
-- Keeping only the most recent version of each transaction
WHERE record_rank = 1;


SELECT COUNT(*)
FROM `data_tel_silver.stg_billing`
GROUP BY transaction_id
HAVING COUNT(*) > 1;