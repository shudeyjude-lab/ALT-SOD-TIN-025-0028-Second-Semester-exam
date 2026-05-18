-----------------------------  STAGE 4 The Data Warehouse Table ----------------------------- 

/* dw_user_analytics is the final destination: a single, wide table that joins all staging and transformation outputs into one unified view. This is the table that analysts, dashboards, and downstream models will query. */

CREATE OR REPLACE TABLE `data_warehouse.dw_user_analytics` AS
SELECT 
    -- 1. Core Dimensions (Sourced from stg_customers - now including created_at)
    c.customer_id,
    c.name AS customer_name,
    c.email,
    c.country,
    c.created_at, -- Added this to make it available for analytical queries

    -- 2. Financial Metrics (Sourced from agg_user_revenue)
    COALESCE(r.total_revenue, 0) AS total_revenue,
    COALESCE(r.total_transactions, 0) AS total_transactions,

    -- 3. Network Usage Metrics (Sourced from agg_user_usage)
    COALESCE(u.total_data_used_mb, 0) AS total_data_used_mb,
    COALESCE(u.avg_session_duration_sec, 0) AS avg_session_duration_sec,
    COALESCE(u.total_sessions, 0) AS total_sessions,

    -- 4. Normalized Financials (Sourced from agg_arpu)
    COALESCE(a.arpu, 0) AS arpu,

    -- 5. Behavioral Distribution (Sourced from agg_session_distribution)
    COALESCE(s.short_sessions, 0) AS short_sessions,
    COALESCE(s.medium_sessions, 0) AS medium_sessions,
    COALESCE(s.long_sessions, 0) AS long_sessions,

    -- 6. Derived Metric
    COALESCE(u.total_data_used_mb, 0) / NULLIF(COALESCE(u.total_sessions, 0), 0) AS avg_data_per_session_mb

FROM `data_tel_silver.stg_customers` c
LEFT JOIN `data_tel_gold.agg_user_revenue` r ON c.customer_id = r.customer_id
LEFT JOIN `data_tel_gold.agg_user_usage` u ON c.customer_id = u.customer_id
LEFT JOIN `data_tel_gold.agg_arpu` a ON c.customer_id = a.customer_id
LEFT JOIN `data_tel_gold.agg_session_distribution` s ON c.customer_id = s.customer_id;