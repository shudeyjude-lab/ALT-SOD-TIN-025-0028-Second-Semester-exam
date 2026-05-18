/* session_bucket and agg_session_distribution
This is a two-step process. First, label every session in stg_sessions with a session type based on its duration:
•	‘short’ — sessions under 60 seconds.
•	‘medium’ — sessions between 60 and 299 seconds (inclusive).
•	‘long’ — sessions of 300 seconds or more.
Then, from that bucketed table, create an aggregation table with one row per customer containing three columns: short_sessions, medium_sessions, and long_sessions — each a count of the corresponding session type.
 */

CREATE OR REPLACE TABLE `data_tel_silver.session_buckets` AS
SELECT
  session_id,
  customer_id,
  session_duration_sec,
  -- Labeling the sessions based on duration
  CASE
    WHEN session_duration_sec < 60 THEN 'short'
    WHEN session_duration_sec BETWEEN 60 AND 299 THEN 'medium'
    ELSE 'Long'
  END AS session_type
FROM `data_tel_silver.stg_sessions`;

CREATE OR REPLACE TABLE `data_tel_gold.agg_session_distribution` AS
SELECT 
    customer_id,
    -- Pivoting the rows into distinct behavioral count columns
    COUNTIF(session_type = 'short') AS short_sessions,
    COUNTIF(session_type = 'medium') AS medium_sessions,
    COUNTIF(session_type = 'long') AS long_sessions
FROM `data_tel_silver.session_buckets`
GROUP BY customer_id;