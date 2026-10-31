{{
    config(
        materialized = 'incremental',
        unique_key   = 'LISTING_ID'
    )
}}

WITH bronze AS (
    SELECT * FROM {{ ref('bronze_listings') }}

    {% if is_incremental() %}
        WHERE {{ incremental_filter('CREATED_AT', this) }}
    {% endif %}
)

SELECT
    -- Keys
    LISTING_ID,
    HOST_ID,

    -- Transformation 1: trim and uppercase the column values
    {{ trimmer('PROPERTY_TYPE') }}                              AS PROPERTY_TYPE,
    {{ trimmer('ROOM_TYPE') }}                                  AS ROOM_TYPE,
    {{ trimmer('CITY') }}                                       AS CITY,
    {{ trimmer('COUNTRY') }}                                    AS COUNTRY,

    -- Capacity
    ACCOMMODATES,
    BEDROOMS,
    BATHROOMS,

    -- Financials
    PRICE_PER_NIGHT,

    -- Transformation 2: tag macro → LOW/MEDIUM/HIGH price label
    {{ tag('PRICE_PER_NIGHT', 100, 200) }}                      AS PRICE_CATEGORY,

    -- My extra idea 1: IS_ENTIRE_HOME flag from room type
    CASE
        WHEN {{ trimmer('bronze.ROOM_TYPE') }} = 'ENTIRE HOME/APT' THEN TRUE
        ELSE FALSE
    END                                                         AS IS_ENTIRE_HOME,

    -- My extra idea 2: CAPACITY_CATEGORY based on accommodates
    CASE
        WHEN ACCOMMODATES IS NULL OR ACCOMMODATES <= 0 THEN 'UNKNOWN'
        WHEN ACCOMMODATES <= 2  THEN 'SOLO/COUPLE'
        WHEN ACCOMMODATES <= 4  THEN 'SMALL GROUP'
        WHEN ACCOMMODATES <= 8  THEN 'LARGE GROUP'
        ELSE 'BULK'
    END                                                         AS CAPACITY_CATEGORY,

    -- My extra idea 3: PRICE_PER_PERSON (useful for group bookings)
    CASE
        WHEN ACCOMMODATES > 0
            THEN ROUND({{ safe_divide('PRICE_PER_NIGHT', 'ACCOMMODATES') }}, 2)
        ELSE NULL
    END                                                         AS PRICE_PER_PERSON,

    CREATED_AT

FROM bronze

WHERE LISTING_ID IS NOT NULL
