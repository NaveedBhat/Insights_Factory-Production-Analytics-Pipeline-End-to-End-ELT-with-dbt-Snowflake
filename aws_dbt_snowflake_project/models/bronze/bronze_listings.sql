{{ config(materialized = 'incremental', unique_key = 'LISTING_ID') }}

SELECT * FROM {{ source('staging', 'listings') }}

{% if is_incremental() %}
    WHERE {{ incremental_filter('CREATED_AT', this) }}
{% endif %}
