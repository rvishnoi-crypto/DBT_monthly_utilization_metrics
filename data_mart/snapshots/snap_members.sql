{% snapshot snap_members %}

{{
  config(
    target_schema='data_mart',
    unique_key='member_id',
    strategy='check',
    check_cols=['province']  
  )
}}

SELECT *
FROM {{ ref('hist_members') }} -- later change to stg_members for daily

{% endsnapshot %}
