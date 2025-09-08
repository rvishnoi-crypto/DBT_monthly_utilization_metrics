{% snapshot snap_organizations %}

{{
  config(
    target_schema='data_mart',
    unique_key='organization_id',
    strategy='check',
    check_cols=['programs'] 
  )
}}


SELECT *
FROM {{ ref('hist_organizations') }} -- use stg_organizations later

{% endsnapshot %}
