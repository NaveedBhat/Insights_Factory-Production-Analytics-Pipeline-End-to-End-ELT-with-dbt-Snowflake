
-- THESE ARE DIMENSION TABLES AND HERE WE PUT NON NUMERICE COLUMNS LIKE BOOKING_STATUS(confirmerd or not )
{{
    config(
        materialized = 'ephemeral'
    )
}}

WITH bookings AS
(
    SELECT
        BOOKING_ID,
        BOOKING_DATE,
        BOOKING_STATUS,
        CREATED_AT
    FROM
        {{ ref('obt') }}
)
SELECT * FROM bookings

