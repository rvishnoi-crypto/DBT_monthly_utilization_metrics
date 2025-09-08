{{ config(materialized='view') }}

WITH episodes_with_org AS (
    SELECT
        f.episode_id,
        f.member_id,
        f.episode_created_at,
        DATE_TRUNC('month', f.episode_created_at) AS calendar_month,
        o.organization_id,
        o.organization_name
    FROM {{ ref('episode_fact') }} f
    JOIN {{ ref('member_dim') }} m
      ON f.member_id = m.member_id
     AND f.episode_created_at >= m.dbt_valid_from
     AND (f.episode_created_at < m.dbt_valid_to OR m.dbt_valid_to IS NULL)
    JOIN {{ ref('organization_dim') }} o
      ON f.organization_id = o.organization_id
     AND f.episode_created_at >= o.dbt_valid_from
     AND (f.episode_created_at < o.dbt_valid_to OR o.dbt_valid_to IS NULL)
),

episodes_by_org_month AS (
    SELECT
        calendar_month,
        organization_id,
        organization_name,
        COUNT(DISTINCT episode_id) AS count_of_episodes
    FROM episodes_with_org
    GROUP BY 1, 2, 3
),

months AS (
    SELECT DISTINCT DATE_TRUNC('month', episode_created_at) AS calendar_month
    FROM {{ ref('episode_fact') }}
),

eligible_members AS (
    SELECT
        m.organization_id,
        DATE_TRUNC('month', mo.calendar_month) AS calendar_month,
        COUNT(DISTINCT m.member_id) AS count_of_eligible_members
    FROM months mo
    JOIN {{ ref('member_dim') }} m
      ON m.dbt_valid_from <= mo.calendar_month + INTERVAL '1 MONTH' - INTERVAL '1 DAY'
     AND (m.dbt_valid_to IS NULL OR m.dbt_valid_to >= mo.calendar_month + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
    GROUP BY 1, 2
)

SELECT
    e.calendar_month,
    e.organization_id,
    e.organization_name,
    em.count_of_eligible_members,
    e.count_of_episodes AS count_of_episodes_created,
    ROUND(
        CAST(e.count_of_episodes AS DOUBLE) / NULLIF(em.count_of_eligible_members, 0),
        4
    ) AS utilization_rate
FROM episodes_by_org_month e
JOIN eligible_members em
  ON e.calendar_month = em.calendar_month
 AND e.organization_id = em.organization_id
ORDER BY e.calendar_month, e.organization_id, e.organization_name
