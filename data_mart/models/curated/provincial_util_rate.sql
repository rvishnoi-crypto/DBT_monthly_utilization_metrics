{{ config(materialized='view') }}

WITH episodes_with_province AS (
    SELECT
        f.episode_id,
        f.member_id AS member_id,
        f.episode_created_at,
        m.province
    FROM {{ ref('episode_fact') }} f
    JOIN {{ ref('member_dim') }} m
    ON  
        f.member_id = m.member_id AND
        f.episode_created_at >= m.dbt_valid_from AND
        (f.episode_created_at < m.dbt_valid_to OR m.dbt_valid_to IS NULL)
),

episodes_by_province_month AS (
    SELECT
        DATE_TRUNC('month', episode_created_at) AS calendar_month,
        province,
        COUNT(DISTINCT episode_id) AS count_of_episodes -- Since status is diff based on ts
    FROM episodes_with_province
    GROUP BY 1, 2
),

months AS (
    SELECT DISTINCT DATE_TRUNC('month', episode_created_at) AS calendar_month
    FROM {{ ref('episode_fact') }}
),

eligible_members AS (
    SELECT
        m.province,
        DATE_TRUNC('month', mo.calendar_month) AS calendar_month,
        COUNT(DISTINCT m.member_id) AS count_of_eligible_members
    FROM months mo
    JOIN {{ ref('member_dim') }} m
      ON m.dbt_valid_from <= mo.calendar_month + INTERVAL '1 MONTH' - INTERVAL '1 DAY'
     AND (m.dbt_valid_to IS NULL OR m.dbt_valid_to >= mo.calendar_month + INTERVAL '1 MONTH' - INTERVAL '1 DAY')
    GROUP BY 1, 2
) -- Checks validity on last day

SELECT
    STRFTIME(e.calendar_month, '%Y-%m') as calendar_month,
    e.province,
    em.count_of_eligible_members,
    e.count_of_episodes AS count_of_episodes_created,
    ROUND(
        CAST(e.count_of_episodes AS DOUBLE) / NULLIF(em.count_of_eligible_members, 0),
        4
    ) AS utilization_rate
FROM episodes_by_province_month e
JOIN eligible_members em
  ON e.calendar_month = em.calendar_month
 AND e.province = em.province
ORDER BY e.calendar_month, e.province