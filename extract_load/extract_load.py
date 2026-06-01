# extract_load.py
# PURPOSE: Downloads NYC property sales data and loads it into Snowflake
# This is the EXTRACT and LOAD step of our ELT pipeline

import pandas as pd
import snowflake.connector
import requests
import os

# ─────────────────────────────────────────────
# STEP 1 — EXTRACT
# Download NYC property sales CSV from open data portal
# In real work this would be an API call or database connection
# Here we use public NYC data to demonstrate the same pattern
# ─────────────────────────────────────────────

def extract_data():
    print("Extracting NYC property sales data...")
    
    url = "https://data.cityofnewyork.us/api/views/usep-8jbt/rows.csv?accessType=DOWNLOAD"
    
    # Download the CSV file
    df = pd.read_csv(url, thousands=',')
    
    # Basic cleanup of column names
    # Real work: same thing — standardize column names before loading
    df.columns = [col.strip().upper().replace(" ", "_") for col in df.columns]
    
    print(f"Extracted {len(df)} rows from NYC Open Data")
    return df


# ─────────────────────────────────────────────
# STEP 2 — LOAD
# Load the raw data into Snowflake as-is
# We do NOT transform here — that is dbt's job
# This follows the ELT pattern — load raw, transform later
# ─────────────────────────────────────────────

def load_to_snowflake(df):
    print("Connecting to Snowflake...")
    
    # Snowflake connection
    # In real work these come from environment variables or a secrets manager
    # NEVER hardcode passwords — that is why we use os.environ
    conn = snowflake.connector.connect(
        user=os.environ.get("SNOWFLAKE_USER"),
        password=os.environ.get("SNOWFLAKE_PASSWORD"),
        account=os.environ.get("SNOWFLAKE_ACCOUNT"),
        warehouse="COMPUTE_WH",
        database="NYC_PROPERTY_RAW",
        schema="PUBLIC"
    )
    
    cursor = conn.cursor()
    
    # Create database and schema if they don't exist
    cursor.execute("CREATE DATABASE IF NOT EXISTS NYC_PROPERTY_RAW")
    cursor.execute("USE DATABASE NYC_PROPERTY_RAW")
    cursor.execute("CREATE SCHEMA IF NOT EXISTS PUBLIC")
    
    # Create the raw table
    # This is our RAW layer — exact copy of source data, no transformations
    cursor.execute("""
        CREATE OR REPLACE TABLE RAW_PROPERTY_SALES (
            BOROUGH               VARCHAR,
            NEIGHBORHOOD          VARCHAR,
            BUILDING_CLASS_CATEGORY VARCHAR,
            TAX_CLASS_AT_PRESENT  VARCHAR,
            BLOCK                 VARCHAR,
            LOT                   VARCHAR,
            EASE_MENT             VARCHAR,
            BUILDING_CLASS_AT_PRESENT VARCHAR,
            ADDRESS               VARCHAR,
            APARTMENT_NUMBER      VARCHAR,
            ZIP_CODE              VARCHAR,
            RESIDENTIAL_UNITS     VARCHAR,
            COMMERCIAL_UNITS      VARCHAR,
            TOTAL_UNITS           VARCHAR,
            LAND_SQUARE_FEET      VARCHAR,
            GROSS_SQUARE_FEET     VARCHAR,
            YEAR_BUILT            VARCHAR,
            TAX_CLASS_AT_TIME_OF_SALE VARCHAR,
            BUILDING_CLASS_AT_TIME_OF_SALE VARCHAR,
            SALE_PRICE            VARCHAR,
            SALE_DATE             VARCHAR
        )
    """)
    
    print(f"Loading {len(df)} rows into Snowflake RAW layer...")
    
    # Write dataframe to Snowflake
    from snowflake.connector.pandas_tools import write_pandas
    success, num_chunks, num_rows, _ = write_pandas(
        conn, df, "RAW_PROPERTY_SALES"
    )
    
    print(f"Successfully loaded {num_rows} rows into Snowflake")
    cursor.close()
    conn.close()


# ─────────────────────────────────────────────
# MAIN — runs both steps in sequence
# ─────────────────────────────────────────────

if __name__ == "__main__":
    # Step 1 — Extract
    df = extract_data()
    
    # Step 2 — Load
    load_to_snowflake(df)
    
    print("ELT Extract and Load complete. Ready for dbt transformations.")
