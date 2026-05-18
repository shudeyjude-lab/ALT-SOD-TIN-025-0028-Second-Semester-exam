/* Create a staging table from src_network_sessions that:
•	Casts start_time and end_time to proper timestamp types.
•	Replaces NULL data_used_mb values with zero.
•	Adds a derived column, session_duration_sec, containing the session length in seconds.
•	Sets session_duration_sec to zero for any records where end_time is not later than start_time.
*/

CREATE OR REPLACE TABLE `data_tel_silver.stg_sessions` AS
WITH cleaned_sessions AS (
  SELECT
    session_id,
    customer_id,
    -- Casting text to proper timestamps
    CAST(start_time AS TIMESTAMP) AS start_timestamp,
    CAST(end_time AS TIMESTAMP) AS end_timestamp,
    -- Replacing NULL data usage with 0
    COALESCE(data_used_mb, 0) AS data_used_mb
  FROM `data_tel_bronze.src_network_sessions`
),
duration_calculation AS (
  SELECT
    *,
    -- Calculating difference in seconds
    TIMESTAMP_DIFF(end_timestamp, start_timestamp, SECOND) AS raw_duration
FROM cleaned_sessions
)
SELECT
  session_id,
  customer_id,
  start_timestamp,
  end_timestamp,
  data_used_mb,
  -- Guarding against negative durations (End time before start time)
  CASE
    WHEN raw_duration > 0 THEN raw_duration
    ELSE 0
  END AS session_duration_sec
FROM duration_calculation;