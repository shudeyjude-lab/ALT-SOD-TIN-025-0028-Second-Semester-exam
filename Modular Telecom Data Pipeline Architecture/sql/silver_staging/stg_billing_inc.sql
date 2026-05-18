/* Re-running the full staging pipeline from scratch every day is viable when data volumes are small. As the dataset grows, it becomes expensive. An incremental load solves this by processing only the new records that arrived since the last run.

===================================================================
INCREMENTAL INSIGHT PIPELINE: stg_billing
===================================================================
*/

INSERT INTO `data_tel_silver.stg_billing` (transaction_id, customer_id, transaction_timestamp, amount)
WITH high_water_mark AS (
    -- Identify the most recent transaction timestamp already in Silver
    SELECT COALESCE(MAX(transaction_timestamp), TIMESTAMP('1970-01-01 00:00:00')) AS max_timestamp
    FROM `data_tel_silver.stg_billing`
),
new_raw_records AS (
    SELECT 
        transaction_id,
        customer_id,
        SAFE_CAST(transaction_date AS TIMESTAMP) AS transaction_timestamp,
        COALESCE(amount, 0) AS amount
    FROM `data_tel_bronze.src_billing_transactions`
    WHERE SAFE_CAST(transaction_date AS TIMESTAMP) > (SELECT max_timestamp FROM high_water_mark)
),
deduplicated_records AS (
    SELECT 
        transaction_id,
        customer_id,
        transaction_timestamp,
        amount,
        ROW_NUMBER() OVER(
            PARTITION BY transaction_id 
            ORDER BY transaction_timestamp DESC
        ) AS row_num
    FROM new_raw_records
    WHERE transaction_id IS NOT NULL 
      AND customer_id IS NOT NULL
)
SELECT 
    transaction_id,
    customer_id,
    transaction_timestamp,
    amount
FROM deduplicated_records
WHERE row_num = 1;