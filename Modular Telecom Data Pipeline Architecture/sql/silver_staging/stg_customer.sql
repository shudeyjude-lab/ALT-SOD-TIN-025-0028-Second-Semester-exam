/* Create a staging table from src_customers that:
•	Standardises name capitalisation so that every word begins with an uppercase letter and the rest are lowercase.
•	Converts email to all lowercase.
•	Fills any NULL country values with the string ‘Nigeria’.
•	Casts created_at from text to a timestamp.
*/

CREATE OR REPLACE TABLE `data_tel_silver.stg_customers` AS
SELECT
  customer_id,
  -- Standardizing name capitalization (e.g., "JOHN DOE" -> "John Doe")
  INITCAP(name) AS name,
  -- Converting emails to lowercase for consistent lookups
  LOWER(email) AS email,
  -- Filling missing countries with 'Nigeria'
  COALESCE(country, 'Nigeria') AS country,
  -- Casting the signup date to a proper timestamp
  CAST(created_at AS TIMESTAMP) AS created_at
FROM `data_tel_bronze.src_customers`;