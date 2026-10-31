{{ config(materialized = 'incremental', unique_key = 'BOOKING_ID') }}

SELECT * FROM {{ source('staging', 'bookings') }}

{% if is_incremental() %}
    WHERE {{ incremental_filter('CREATED_AT', this) }}
{% endif %}
