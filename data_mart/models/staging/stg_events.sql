{{ config(
    materialized='view'
) }}

WITH cleaned_events AS (
    SELECT
        event_id,
        timestamp AS event_timestamp,
        event_type,
        CAST(data->>'episode_id' AS INTEGER) AS episode_id,
        CAST(data->>'subject_member_id' AS INTEGER) AS subject_member_id,
        CAST(data->>'issue_type' AS VARCHAR) AS issue_type,
        CAST(data->>'triage_recommendation' AS VARCHAR) AS triage_recommendation,
        UPPER(TRIM(CAST(data->>'status' AS VARCHAR))) AS status,
        current_timestamp AS initial_load_ts
    FROM raw.events
)

SELECT *
FROM cleaned_events
WHERE CAST(event_timestamp AS DATE) >= CURRENT_DATE - INTERVAL '1 DAY'
