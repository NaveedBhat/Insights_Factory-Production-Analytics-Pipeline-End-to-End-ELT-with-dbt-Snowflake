{{
    config(
        materialized = 'ephemeral'
    )
}}

WITH listings AS
(
    SELECT DISTINCT
        LISTING_ID,
        PROPERTY_TYPE,
        ROOM_TYPE,
        CITY,
        COUNTRY,
        PRICE_CATEGORY,       -- instructor names this PRICE_PER_NIGHT_TAG; our OBT column is PRICE_CATEGORY (same tag() macro output)
        LISTING_CREATED_AT
    FROM
        {{ ref('obt') }}
)
SELECT * FROM listings
