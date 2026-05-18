/* Create a table that aggregates stg_sessions to produce, per customer:
•	total_data_used_mb — total megabytes consumed across all sessions.
•	avg_session_duration_sec — the average session duration in seconds.
•	total_sessions — a count of all sessions.
*/

CREATE OR REPLACE TABLE `data_tel_gold.agg_user_usage` AS
SELECT
  customer_id,
  -- Total data consumed across all network activity
  SUM(data_used_mb) AS total_data_used_mb,
  -- Average duration of a user's connection
  AVG(session_duration_sec) AS avg_session_duration_sec,
  -- Total count of session events
  COUNT(session_id) AS total_sessions
FROM `data_tel_silver.stg_sessions`
GROUP BY customer_id;