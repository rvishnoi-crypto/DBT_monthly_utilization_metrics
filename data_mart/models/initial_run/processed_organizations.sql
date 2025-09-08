{{ config(
    materialized='table'
) }}

SELECT
    id AS organization_id,
    TRIM(name) AS name,
    ARRAY_SORT(programs) AS programs,
    churned_at,
    created_at,
    CAST(loaded_at AT TIME ZONE 'UTC' AS TIMESTAMP) AS raw_loaded_at,
    CAST(current_timestamp AS TIMESTAMP) AS process_load_ts
FROM raw.organizations
