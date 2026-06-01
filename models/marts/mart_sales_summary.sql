-- mart_sales_summary.sql
-- PURPOSE: Business-ready aggregated sales analytics by borough and neighborhood
-- This is the MART layer — final transformation step
-- Analysts, dashboards, and BI tools query THIS table, not raw or staging
-- In real work: same pattern — marts are what Power BI or Tableau connects to

-- ref() tells dbt to run staging model first, then this one
-- dbt figures out the order automatically — no manual scheduling needed

WITH property_sales AS (

    -- Read from our staging model — NOT from raw
    -- This is the dbt lineage chain: raw → staging → mart
    SELECT * FROM {{ ref('stg_property_sales') }}

),

-- Filter out invalid records before aggregating
-- In real work you always filter bad data before business metrics
valid_sales AS (

    SELECT *
    FROM property_sales
    WHERE
        sale_price > 0                  -- Remove $0 sales (transfers, gifts)
        AND sale_price IS NOT NULL
        AND sale_date IS NOT NULL
        AND neighborhood IS NOT NULL
        AND borough_id IS NOT NULL

),

-- Map borough codes to names
-- NYC borough codes: 1=Manhattan, 2=Bronx, 3=Brooklyn, 4=Queens, 5=Staten Island
borough_mapped AS (

    SELECT
        *,
        CASE borough_id
            WHEN 1 THEN 'Manhattan'
            WHEN 2 THEN 'Bronx'
            WHEN 3 THEN 'Brooklyn'
            WHEN 4 THEN 'Queens'
            WHEN 5 THEN 'Staten Island'
            ELSE 'Unknown'
        END AS borough_name
    FROM valid_sales

),

-- Final aggregation — this is what the business actually wants to see
final AS (

    SELECT
        borough_name,
        neighborhood,
        building_class_category,

        -- Time dimensions for trend analysis
        DATE_TRUNC('year', sale_date)   AS sale_year,
        DATE_TRUNC('month', sale_date)  AS sale_month,

        -- Volume metrics
        COUNT(*)                        AS total_sales,
        COUNT(DISTINCT address)         AS unique_properties_sold,

        -- Price metrics
        AVG(sale_price)                 AS avg_sale_price,
        MEDIAN(sale_price)              AS median_sale_price,
        MIN(sale_price)                 AS min_sale_price,
        MAX(sale_price)                 AS max_sale_price,
        SUM(sale_price)                 AS total_sales_volume,

        -- Size metrics
        AVG(gross_square_feet)          AS avg_square_feet,
        AVG(sale_price / NULLIF(gross_square_feet, 0)) AS avg_price_per_sqft

    FROM borough_mapped
    GROUP BY
        borough_name,
        neighborhood,
        building_class_category,
        DATE_TRUNC('year', sale_date),
        DATE_TRUNC('month', sale_date)

)

SELECT * FROM final
ORDER BY total_sales DESC
