{{ config(
    materialized='table'
) }}

-- Numbers by id, province combinations
WITH numbered AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY member_id, province
            ORDER BY raw_loaded_at 
        ) AS rn
    FROM {{ ref('processed_members') }}
),

-- SCD implementation initial load (after initial, dbt will take care of it in snapshots)
validity AS (
    SELECT
        member_id,
        name,
        email,
        date_of_birth,
        province,
        organization_id,
        eligible_programs,
        raw_loaded_at AS dbt_valid_from,
        created_at,
        LEAD(raw_loaded_at) OVER (
            PARTITION BY member_id
            ORDER BY raw_loaded_at
        ) AS dbt_valid_to,
        CASE
            WHEN LEAD(raw_loaded_at) OVER (PARTITION BY member_id ORDER BY raw_loaded_at) IS NULL
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
ORDER BY member_id, dbt_valid_from
