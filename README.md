# Telecom User Analytics Data Pipeline

An end-to-end data engineering pipeline that extracts raw telecommunications data from upstream transactional systems, ingests it into Google BigQuery, and orchestrates a multi-layered (Medallion) data warehouse transformation sequence using Python and BigQuery Standard SQL.

## Architecture & Data Lineage

The data infrastructure follows a strict Medallion Architecture, ensuring that data transformations, cleansing, and business logic are completely decoupled from application orchestration and computed 100% within Google BigQuery.

```text
  [Local Simulation] or [PostgreSQL Source]
                        │
                        ▼ (Ingestion Layer: ingestion/ingest_pg.py)
┌────────────────────────────────────────────────────────────────────────┐
│                        GOOGLE BIGQUERY PLATFORM                        │
│                                                                        │
│   data_tel_bronze (Bronze Layer / Raw Land Zone)                       │
│   └── src_customers, src_billing_transactions, src_network_sessions    │
│        │                                                               │
│        ▼ (Silver Layer: sql/silver_staging/ via orchestrator loop)     │
│   data_tel_silver (Staging Layer / Cleansed & Deduplicated)            │
│   └── stg_customers, stg_billing (Incremental), stg_sessions           │
│        │                                                               │
│        ▼ (Gold Layer: sql/gold_metrics/)                               │
│   data_tel_gold (Aggregation Layer / KPIs)                             │
│   └── agg_user_revenue, agg_user_usage, agg_arpu, agg_session_dist     │
│        │                                                               │
│        ▼ (Warehouse Layer: sql/data_warehouse/)                        │
│   data_tel_gold.dw_user_analytics (Wide Unified Reporting Matrix)      │
│        │                                                               │
│        ▼ (Analytics Layer: sql/analytical_queries/)                    │
│   On-Demand Business Intelligence Snapshots & Views                    │
└────────────────────────────────────────────────────────────────────────┘
Bronze (Raw Layer): Universal landing site for raw, unverified data mirrors pulled directly from transactional file dumps or database boundaries.

Silver (Staging Layer): Data cleaning and structural normalization models. Handles structural string transformations (email lowercasing), schema conversions (SAFE_CAST string dates to TIMESTAMP), duplicate mitigation via window ranking functions (ROW_NUMBER()), and negative-duration boundary guards.

Gold (Metrics & Warehouse Layer): Downstream aggregations computed across critical user dimensions, culminating in a highly denormalized, wide warehouse reporting asset (dw_user_analytics) optimized for high-speed analytical consumption, BI dashboards, and ad-hoc reporting.

Repository Structure
The project maintains a strict separation of concerns—keeping orchestration, validation, and execution logic in Python, and infrastructure transform profiles completely in pure SQL:

Plaintext
telecom-analytics-pipeline/
├── .gitignore                  # Prevents tracking of secrets, keys, local datasets, and caches
├── README.md                   # System, architecture, and deployment documentation
├── requirements.txt            # System dependencies (google-cloud-bigquery, python-dotenv, etc.)
├── main.py                     # Central workflow pipeline orchestrator and entry point
│
├── config/                     # System Settings, Environment Variables & Quality Gates
│   ├── tel.env                 # Local environment config (credentials, project variables)
│   └── validate.py             # Data quality assertions, connection health, and freshness checks
│
├── ingestion/                  # Extraction & Load Layer (Bronze Stage)
│   └── ingest_pg.py            # Loads raw mock data assets from local disk into BigQuery Bronze
│
├── raw_data/                   # Local-only staging directory for generated source CSV/JSON records
│   ├── customers_mock.csv
│   └── sessions_mock.json
│
├── scripts/                    # Core Python Automation & Execution Engine
│   ├── bigquery_orchestrator.py # Sequentially executes and loops through the SQL warehouse lineage
│   ├── generate_data.py        # Generates mock telecom data profiles and drops records into raw_data/
│   └── pipeline.py             # Legacy baseline script / reference playground
│
└── sql/                        # Pure Infrastructure Transformation Blueprints (BigQuery Engine)
    ├── silver_staging/         # Silver cleansing transformations (stg_*)
    │   ├── stg_billing_inc.sql # High-water mark incremental record appender
    │   ├── stg_customers.sql   # Customer profile parsing and structural case cleaning
    │   └── stg_sessions.sql    # Session duration metrics and data type adjustments
    │
    ├── gold_metrics/           # Gold business logic metrics and aggregated summaries (agg_*)
    │   ├── agg_arpu.sql
    │   ├── agg_monthly_revenue.sql
    │   ├── agg_session_distribution.sql
    │   ├── agg_user_revenue.sql
    │   └── agg_user_usage.sql
    │
    ├── data_warehouse/         # Target Data Warehouse Materialization
    │   └── dw_user_analytics.sql # Wide, integrated analytical core reporting matrix
    │
    └── analytical_queries/     # On-demand reports and ad-hoc business intelligence
        ├── top_customers.sql   # Tracks top 10 customers by lifetime revenue
        ├── segmentation.sql    # Categorizes users into High, Mid, and Low Value tiers
        ├── churn_risk.sql      # Advanced churn analysis with Account Maturity Guard
        └── revenue_vs_usage_mismatch.sql
Key Engineering Paradigms Implemented
Idempotency: Every SQL file in the core transformation layer uses defensive structures (CREATE OR REPLACE TABLE or tightly defined conditional boundaries). This ensures the pipeline can be executed repeatedly on identical data frames without duplicating rows or creating analytical drift.

Advanced Incremental Architecture: The stg_billing_inc.sql engine implements a dynamic high-water mark architecture. Using scalar subqueries (SELECT COALESCE(MAX(transaction_timestamp)...)), it reads the destination staging table and automatically processes only net-new incoming source rows, cutting compute costs.

Pre-Flight Data Quality Checks: The validation layer (config/validate.py) intercepts execution at runtime. It runs a diagnostic health check on cloud connections and evaluates the operational freshness of the staging layer. If data stays stale past a 24-hour window, an alert is triggered.

Maturity-Guarded Churn Analysis: The reporting query layer features an explicit account age maturity loop (TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), created_at, DAY)). This ensures new users are not falsely categorized as "High Churn Risk" simply because they haven't had time to log 5 sessions yet.

Absolute Local Path Auditing: Python orchestration dependencies use path-agnostic resolution (Path(__file__).resolve()) to reference your local environment file (config/tel.env) and Google Cloud keys safely from any running execution terminal workspace context.

Getting Started
Prerequisites
Python 3.10 or higher

Google Cloud Platform (GCP) account with BigQuery Admin permissions active

A localized or cloud Google Cloud Service Account JSON Key

1. Installation & Environment Setup
Clone this repository to your system, step inside the root folder space, set up your isolated virtual environment, and load baseline packages:

Bash
git clone [https://github.com/your-username/telecom-analytics-pipeline.git](https://github.com/your-username/telecom-analytics-pipeline.git)
cd telecom-analytics-pipeline

python -m venv .env
# On Windows (PowerShell):
.env\Scripts\activate
# On macOS/Linux:
source .env/bin/activate

pip install -r requirements.txt
2. Configure Credentials & Secrets
Locate or create your local environment file tel.env and place it inside the config/ directory.

Store your Google Application Environment variable inside it, pointing explicitly to your service account credential key file:

Plaintext
# config/tel.env contents
GOOGLE_APPLICATION_CREDENTIALS="config/data-tel-32e8869a349f.json"
BIGQUERY_PROJECT_ID="your-gcp-project-id"
Place your matching credential key file safely inside the same configuration sub-directory:
config/data-tel-32e8869a349f.json

Note: The config/tel.env file and all .json credential keys are explicitly added to your project's .gitignore policy and will never be exposed to public version control.

3. Running the Pipeline End-to-End
To execute your pipeline components sequentially (generating data, validating schemas, ingesting files into Bronze tables, and orchestrating the multi-tiered BigQuery warehouse build), execute the primary system orchestrator:

Bash
python main.py
Monitoring Outputs & Pipeline Flow
The orchestration engine outputs clean tracking sequences directly to your execution terminal:

Stage 1 (Simulation Engine): Simulates transaction streams via scripts/generate_data.py and outputs mock items into raw_data/.

Stage 2 (Validation Engine): Tests environment configurations and executes data quality assertions.

Stage 3 & 4 (Ingestion/Sync): Dispatches local file streams into data_tel_bronze on Google Cloud.

Stage 5 (BigQuery Orchestrator): Triggers your structured SQL lineage sequentially via scripts/bigquery_orchestrator.py. When the execution cursor moves into the analytical_queries/ layer, a clean summary table is printed to your screen for review.

If any SQL transformation script encounters a compile error or schema mismatch, main.py terminates the pipeline immediately to protect your data warehouse integrity.
