import os
from scripts.generate_data import generate_all_data
from ingestion.ingest_pg import ingest_data
from validate import run_validation
from scripts.pipeline import move_local_to_bq
from scripts.bigquery_orchestrator import run_bigquery_transformations

if __name__ == "__main__":
    generate_all_data()
    ingest_data()
    run_validation()
    move_local_to_bq()
    run_bigquery_transformations()