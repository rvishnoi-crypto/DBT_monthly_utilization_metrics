{{ config(
    materialized='table'
) }}

SELECT
    organization_id,
    name AS organization_name,
    programs,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_current,
    created_at
FROM {{ ref('snap_organizations') }}
