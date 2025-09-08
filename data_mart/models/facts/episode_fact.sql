{{ config(
    materialized='table'
) }}

WITH fact_with_org AS (
    SELECT
        e.event_id, -- PK
        e.episode_id,
        e.subject_member_id AS member_id,
        e.event_timestamp AS episode_created_at,
        e.issue_type,
        e.triage_recommendation,
        e.status,
        m.organization_id
    FROM {{ ref('snap_events') }} e -- change to stg_events
    JOIN {{ ref('snap_members') }} m
      ON e.subject_member_id = m.member_id
     AND e.event_timestamp >= m.dbt_valid_from
     AND (e.event_timestamp < m.dbt_valid_to OR m.dbt_valid_to IS NULL)
)

SELECT *
FROM fact_with_org