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

def ingest_data():
    # 1. Initialize Connection
    engine = get_pg_engine()
    raw_folder = "raw_data"
    target_schema = "raw_schema"

    # Ensure the schema exists via Python (Safety First!)
    with engine.connect() as conn:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {target_schema};"))
        conn.commit()

    # Automatically find all CSV files in the folder
    files = [f for f in os.listdir(raw_folder) if f.endswith('.csv')]
    
    print(f" Ingesting {len(files)} files into schema '{target_schema}'...")

    for file_name in files:
        # Strip '.csv' to get the table name (e.g., 'src_customers')
        table_name = os.path.splitext(file_name)[0]
        file_path = os.path.join(raw_folder, file_name)

        print(f" Loading {file_name} -> {target_schema}.{table_name}...")
            
        # Use chunks for large files (1.5M and 3M rows) to save memory
        chunksize = 100_000
        first_chunk = True
            
        for chunk in pd.read_csv(file_path, chunksize=chunksize):
            # 'replace' will drop and recreate the table on the first chunk, s'append' will add the remaining chunks
            mode = 'replace' if first_chunk else 'append'
                
            chunk.to_sql(
                name=table_name, 
                con=engine, 
                schema=target_schema,
                if_exists=mode, 
                index=False,
                method='multi' # Speeds up insertion
            )
            first_chunk = False
            
        print(f" Successfully loaded {file_name} into {table_name}")
        
 