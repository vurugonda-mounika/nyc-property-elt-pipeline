-- stg_property_sales.sql
-- PURPOSE: Clean and standardize raw NYC property sales data
-- This is the STAGING layer — first transformation step
-- In real work: same pattern — clean raw data before business logic touches it

-- {{ ref('') }} is dbt syntax — it tells dbt which table to read from
-- In real work you use this exact syntax to connect models together

WITH source AS (

    -- Read directly from the raw table we loaded with Python
    SELECT * FROM {{ source('nyc_property_raw', 'RAW_PROPERTY_SALES') }}

),

cleaned AS (

    SELECT
        -- Clean borough code — trim spaces, cast to integer
        -- Raw data has extra spaces — this is very common in real pipelines
        TRIM(BOROUGH)::INTEGER                          AS borough_id,

        -- Clean text fields — just trim whitespace
        TRIM(NEIGHBORHOOD)                              AS neighborhood,
        TRIM(BUILDING_CLASS_CATEGORY)                   AS building_class_category,
        TRIM(ADDRESS)                                   AS address,
        TRIM(ZIP_CODE)                                  AS zip_code,

        -- Clean numeric fields
        -- Raw data stores these as text — we cast to proper types
        -- NULLIF handles empty strings — converts them to NULL
        -- TRY_CAST handles bad values safely — returns NULL instead of error
        TRY_CAST(NULLIF(TRIM(RESIDENTIAL_UNITS), '') AS INTEGER)  AS residential_units,
        TRY_CAST(NULLIF(TRIM(COMMERCIAL_UNITS), '') AS INTEGER)   AS commercial_units,
        TRY_CAST(NULLIF(TRIM(TOTAL_UNITS), '') AS INTEGER)        AS total_units,
        TRY_CAST(NULLIF(TRIM(GROSS_SQUARE_FEET), '') AS INTEGER)  AS gross_square_feet,
        TRY_CAST(NULLIF(TRIM(YEAR_BUILT), '') AS INTEGER)         AS year_built,

        -- Clean sale price — remove commas and dollar signs, cast to number
        -- Raw data has values like "$1,500,000" — we strip to 1500000
        TRY_CAST(
            NULLIF(REGEXP_REPLACE(TRIM(SALE_PRICE), '[^0-9]', ''), '')
        AS INTEGER)                                     AS sale_price,

        -- Clean sale date — convert to proper date type
        TRY_CAST(TRIM(SALE_DATE) AS DATE)               AS sale_date,

        -- Keep building class codes as-is
        TRIM(BUILDING_CLASS_AT_TIME_OF_SALE)            AS building_class_code

    FROM source

    -- Remove header rows that sometimes appear in raw NYC data
    WHERE TRIM(BOROUGH) NOT IN ('BOROUGH', '')
    AND BOROUGH IS NOT NULL

)

SELECT * FROM cleaned
