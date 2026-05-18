import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv(dotenv_path="config/tel.env")

def get_pg_engine():
    user = os.getenv("PG_USER")
    pw = os.getenv("PG_PASSWORD")
    host = os.getenv("PG_HOST")
    port = os.getenv("PG_PORT")
    db = os.getenv("PG_DB")

    connection_string = f"postgresql://{user}:{pw}@{host}:{port}/{db}"
    return create_engine(connection_string)


def run_validation():
    engine = get_pg_engine()

    # Define our checks: { "Friendly Name": "SQL Query" }
    checks = {
        "Null IDs in Transaction": "SELECT COUNT(*) FROM raw_schema.src_billing_transactions WHERE transaction_id IS NULL",
        "Null IDs in customers": "SELECT COUNT(*) FROM raw_schema.src_network_sessions WHERE session_id IS NULL",
        "Null IDs in Sessions": "SELECT COUNT(*) FROM raw_schema.src_customers WHERE customer_id IS NULL",
        "Duplicate Transaction IDs": "SELECT COUNT(*) FROM (SELECT transaction_id FROM raw_schema.src_billing_transactions GROUP BY transaction_id HAVING COUNT(*) > 1) AS dups",
        "Duplicate Customer IDs": "SELECT COUNT(*) FROM (SELECT customer_id FROM raw_schema.src_customers GROUP BY customer_id HAVING COUNT(*) > 1) AS dups",
        "Duplicate session IDs": "SELECT COUNT(*) FROM (SELECT session_id FROM raw_schema.src_network_sessions GROUP BY session_id HAVING COUNT(*) > 1) AS dups",
    }

    print("\n --- DATA QUALITY VALIDATION REPORT --- ")
    print(f"{'CHECK NAME':<30} | {'RESULT':<10} | {'STATUS'}")
    print("-" * 60)

    overall_pass = True

    with engine.connect() as conn:
        for check_name, query in checks.items():
            result = conn.execute(text(query)).scalar()

            # Logic: If count is 0,it PASSES. If > 0, it FAILS.
            status = " PASS" if result == 0 else " FAIL"

            if result > 0:
                overall_pass = False
            
            print(f"{check_name:<30} | {result:<10} | {status}")
    print("-" * 60)
    if overall_pass:
        print(" ALL CHECKS PASSED: Data is ready for Silver Layer.")
    else:
        print(" VALIDATION FAILED: Clean data in Staging Layer is required")