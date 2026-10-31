{{ config(materialized = 'incremental', unique_key = 'HOST_ID') }}

SELECT * FROM {{ source('staging', 'hosts') }}

{% if is_incremental() %}
    WHERE {{ incremental_filter('CREATED_AT', this) }}
{% endif %}
