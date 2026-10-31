{{
    config(
        materialized = 'incremental',
        unique_key   = 'BOOKING_ID'
    )
}}
{# unique_key enables UPSERT: UPDATE if BOOKING_ID exists, INSERT if new #}

WITH bronze AS (
    SELECT * FROM {{ ref('bronze_bookings') }}

    {% if is_incremental() %}
        WHERE {{ incremental_filter('CREATED_AT', this) }}
    {% endif %}
)

SELECT
    -- Keys
    BOOKING_ID,
    LISTING_ID,

    -- Dates
    BOOKING_DATE,
    CREATED_AT,

    -- Booking details
    NIGHTS_BOOKED,
    {{ trimmer('BOOKING_STATUS') }}                            AS BOOKING_STATUS,

    -- Financials
    BOOKING_AMOUNT,
    CLEANING_FEE,
    SERVICE_FEE,

    -- BOOKING_AMOUNT covers the stay; missing optional fees contribute zero.
    ROUND(BOOKING_AMOUNT + COALESCE(CLEANING_FEE, 0)
        + COALESCE(SERVICE_FEE, 0), 2)                           AS TOTAL_AMOUNT,


    -- Divide the stay amount by nights, protecting against a zero denominator.
    -- Named EFFECTIVE_NIGHTLY_RATE to distinguish from the listing's advertised PRICE_PER_NIGHT.
    ROUND({{ safe_divide('BOOKING_AMOUNT', 'NIGHTS_BOOKED') }}, 2)  AS EFFECTIVE_NIGHTLY_RATE,

    -- Data quality flag
    CASE
        WHEN {{ trimmer('bronze.BOOKING_STATUS') }} = 'CONFIRMED' THEN TRUE
        ELSE FALSE
    END                                                         AS IS_CONFIRMED

FROM bronze

WHERE BOOKING_ID IS NOT NULL    -- remove bad records
