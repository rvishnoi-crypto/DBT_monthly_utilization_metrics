{{ config(
    materialized='table'
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
        CAST(current_timestamp AS TIMESTAMP) AS process_load_ts
    FROM raw.events
)

SELECT *
FROM cleaned_events