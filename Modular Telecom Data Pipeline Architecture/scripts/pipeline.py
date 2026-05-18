import os
import pandas as pd
from sqlalchemy import create_engine
from google.cloud import bigquery
from dotenv import load_dotenv

load_dotenv(dotenv_path="config/tel.env")

def get_bq_client():
    return bigquery.Client()

def get_pg_engine():
    user = os.getenv("PG_USER")
    pw = os.getenv("PG_PASSWORD")
    host = os.getenv("PG_HOST")
    port = os.getenv("PG_PORT")
    db = os.getenv("PG_DB")

    connection_string = f"postgresql://{user}:{pw}@{host}:{port}/{db}"
    return create_engine(connection_string)

def move_local_to_bq():
    # Initialize Clients
    pg_engine = get_pg_engine()
    bq_client = bigquery.Client()

    project_id = os.getenv("GCP_PROJECT_ID")
    target_dataset = f"{project_id}.data_tel_bronze" # Moving to Bronze

    # List of tables in local raw_schema
    tables = ["src_billing_transactions", "src_customers", "src_network_sessions"]

    print(f" Starting migration from Local Postgres to data_tel_bronze...")

    for table in tables:
        print(f" Extracting {table} from local Postgres...")

        # Extract from Local
        query = f"SELECT * FROM raw_schema.{table}"
        df = pd.read_sql(query, pg_engine)

        # Define BQ Destination
        table_id = f"{target_dataset}.{table}"

        # Load to BigQuery
        # job_config ensures we overwrite the table if it already exists
        job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")
        
        print(f" Uploading {table} to BigQuery...")
        job = bq_client.load_table_from_dataframe(df, table_id, job_config=job_config)
        job.result()  # Wait for completion
        
        print(f" {table} successfully moved to BQ.")