{% snapshot snap_events %}

{{
  config(
    target_schema='data_mart',
    unique_key= ['episode_id','subject_member_id'], 
    strategy = 'check',
    check_cols=['status']  
  )
}}

SELECT *
FROM {{ ref('hist_events') }} -- later change to stg_events for daily

{% endsnapshot %}
