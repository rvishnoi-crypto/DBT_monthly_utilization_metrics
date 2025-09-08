{{ config(
    materialized='table'
) }}

SELECT
    id AS member_id,
    TRIM(name) AS name,
    LOWER(TRIM(email)) AS email,
    date_of_birth,
    UPPER(TRIM(SPLIT_PART(province_of_residence, '-', 2))) AS province,
    organization_id,
    ARRAY_SORT(eligible_programs) AS eligible_programs,
    created_at,
    CAST(loaded_at AT TIME ZONE 'UTC' AS TIMESTAMP) AS raw_loaded_at,
    CAST(current_timestamp AS TIMESTAMP) AS process_load_ts
FROM raw.members
