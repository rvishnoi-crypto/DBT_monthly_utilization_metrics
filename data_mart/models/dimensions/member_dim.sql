{{ config(
    materialized='table'
) }}

SELECT
    member_id,
    name,
    email,
    date_of_birth,
    province,
    organization_id,
    eligible_programs,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_current,
    created_at
FROM {{ ref('snap_members') }}
