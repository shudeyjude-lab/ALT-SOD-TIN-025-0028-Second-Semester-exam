# config/bigquery_orchestrator.py
import sys
from google.cloud import bigquery

# Define the sequential SQL lineage that builds your data warehouse layers
BIGQUERY_TRANSFORMATIONS = [
    "sql/silver_staging/stg_customers.sql",
    "sql/silver_staging/stg_billing_inc.sql",
    "sql/silver_staging/stg_sessions.sql",

    "sql/gold_metrics/agg_user_revenue.sql",
    "sql/gold_metrics/agg_user_usage.sql",
    "sql/gold_metrics/agg_monthly_revenue.sql",
    "sql/gold_metrics/agg_arpu.sql",
    "sql/gold_metrics/agg_session_distribution.sql",

    "sql/data_warehouse/dw_user_analytics.sql",

    "sql/analytical_queries/top_customers.sql",
    "sql/analytical_queries/segmentation.sql",
    "sql/analytical_queries/churn_risk.sql",
    "sql/analytical_queries/revenue_vs_usage_mismatch.sql"
]

def run_bigquery_transformations():
    """Reads and executes all structural SQL warehouse blueprints sequentially in BigQuery."""
    print(" Deploying BigQuery Infrastructure Transformations...")
    print("-" * 60)
    
    try:
        # Initialize the BigQuery client using current environment credentials
        client = bigquery.Client()
    except Exception as e:
        print(f" Authentication Failure: Could not initialize BigQuery client.\nDetails: {e}")
        sys.exit(1)

    for sql_file in BIGQUERY_TRANSFORMATIONS:
        print(f"  Executing Architecture Model: {sql_file}...")
        try:
            with open(sql_file, "r") as file:
                query = file.read()
            
            # Dispatch the SQL blueprint straight to the cloud compute engine
            job = client.query(query)
            job.result()  # Wait for cloud layers to finish materializing
            print(f"       Success.")
        except Exception as e:
            print(f"\n Critical Compilation Error on file {sql_file}!")
            print(f"Details: {e}")
            print(" Pipeline halted to protect downstream target table data integrity.")
            sys.exit(1)

    print("-" * 60)