{{ config(
    materialized='table'
) }}

-- Numbered per episode, member, status combination
WITH numbered AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY episode_id, subject_member_id, status
            ORDER BY event_timestamp -- take the first
        ) AS rn
    FROM {{ ref('processed_events') }}
),

-- SCD2 validity ranges
validity AS (
    SELECT
        event_id,
        episode_id,
        subject_member_id,
        event_type,
        issue_type,
        triage_recommendation,
        status,
        event_timestamp,
        event_timestamp AS dbt_valid_from,
        LEAD(event_timestamp) OVER (
            PARTITION BY episode_id, subject_member_id
            ORDER BY event_timestamp
        ) AS dbt_valid_to,
        CASE
            WHEN LEAD(event_timestamp) OVER (
                PARTITION BY episode_id, subject_member_id
                ORDER BY event_timestamp
            ) IS NULL
            THEN TRUE ELSE FALSE
        END AS dbt_is_current,
        process_load_ts
    FROM numbered
    WHERE rn = 1
)

SELECT *
FROM validity
ORDER BY episode_id, subject_member_id, dbt_valid_from
