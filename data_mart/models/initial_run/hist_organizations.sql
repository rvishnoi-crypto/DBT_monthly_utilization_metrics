{{ config(
    materialized='table'
) }}

-- Assign row numbers per org + programs combination
WITH numbered AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY organization_id, programs
            ORDER BY raw_loaded_at
        ) AS rn
    FROM {{ ref('processed_organizations') }}
),

-- SCD2 logic for initial load
validity AS (
    SELECT
        organization_id,
        name,
        programs,
        churned_at,
        raw_loaded_at AS dbt_valid_from,
        created_at,
        LEAD(raw_loaded_at) OVER (
            PARTITION BY organization_id
            ORDER BY raw_loaded_at
        ) AS dbt_valid_to,
        CASE
            WHEN LEAD(raw_loaded_at) OVER (PARTITION BY organization_id ORDER BY raw_loaded_at) IS NULL
            THEN TRUE
            ELSE FALSE
        END AS dbt_is_current,
        raw_loaded_at,
        process_load_ts
    FROM numbered
    WHERE rn = 1
)

SELECT *
FROM validity
ORDER BY organization_id, dbt_valid_from
