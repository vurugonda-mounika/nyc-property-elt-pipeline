# NYC Property Sales — ELT Pipeline

![Python](https://img.shields.io/badge/Python-3.9-blue)
![Snowflake](https://img.shields.io/badge/Snowflake-Data_Warehouse-29B5E8)
![dbt](https://img.shields.io/badge/dbt-Transformations-FF6F3C)
![SQL](https://img.shields.io/badge/SQL-Data_Modeling-green)

## What This Project Does
Builds a production-style ELT pipeline that extracts NYC property sales data, loads it into Snowflake, and transforms it using dbt into analytics-ready tables — following the same staging → mart pattern used in enterprise data platforms.

## Why I Built This
In my professional work I build ELT pipelines processing millions of property records daily. This project demonstrates the same architecture using public data — making the end-to-end pipeline visible and reproducible.

## Architecture
NYC Open Data (CSV) → Python extract_load.py → Snowflake RAW layer → dbt staging model → dbt mart model → Analytics-ready table

## Tech Stack
| Tool | Purpose |
|------|---------|
| Python | Extract CSV data and load to Snowflake |
| Snowflake | Cloud data warehouse |
| dbt Core | SQL transformations and data tests |
| SQL | Data modeling and aggregations |

## Project Structure
nyc-property-elt-pipeline/
├── README.md
├── .gitignore
├── dbt_project.yml
├── extract_load/
│   └── extract_load.py
├── models/
│   ├── staging/
│   │   └── stg_property_sales.sql
│   ├── marts/
│   │   └── mart_sales_summary.sql
│   └── schema.yml
└── tests/
    └── test_positive_sale_price.sql

## Key Features
- Modular dbt models following staging → mart pattern
- Automated data quality tests using dbt schema tests
- Star schema design optimized for analytical queries
- Python automation for extract and load step

## Data Source
NYC Open Data — Rolling Sales Data
https://data.cityofnewyork.us/City-Government/NYC-Citywide-Rolling-Calendar-Sales/usep-8jbt

## How To Run This Project

Step 1 — Clone the repository
git clone https://github.com/vurugonda-mounika/nyc-property-elt-pipeline.git

Step 2 — Install dependencies
pip install snowflake-connector-python dbt-snowflake pandas requests

Step 3 — Run extract and load
python extract_load/extract_load.py

Step 4 — Run dbt transformations
dbt run
dbt test

## Results
- Raw data loaded into Snowflake RAW database
- Staging layer cleans and standardizes all columns
- Mart layer aggregates sales by borough, neighborhood, and building class
- All dbt data quality tests passing

## Author
Mounika Vurugonda
Senior Data Engineer | Snowflake · dbt · Azure · Databricks
LinkedIn: https://linkedin.com/in/vurugonda-mounika
