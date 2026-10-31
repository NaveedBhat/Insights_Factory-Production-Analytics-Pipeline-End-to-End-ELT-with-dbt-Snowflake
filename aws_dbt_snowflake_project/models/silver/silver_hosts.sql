{{
    config(
        materialized = 'incremental',
        unique_key   = 'HOST_ID'
    )
}}

WITH bronze AS (
    SELECT * FROM {{ ref('bronze_hosts') }}

    {% if is_incremental() %}
        WHERE {{ incremental_filter('CREATED_AT', this) }}
    {% endif %}
)

SELECT
    -- Keys
    HOST_ID,

    -- Transformation: clean host name
    {{ trimmer('HOST_NAME') }}                                  AS HOST_NAME,

    -- Host tenure
    HOST_SINCE,
    DATEDIFF('year', HOST_SINCE, CURRENT_DATE())                AS YEARS_AS_HOST,

    -- Superhost flag (already boolean, keep as-is)
    IS_SUPERHOST,

    -- Response rate
    RESPONSE_RATE,

    -- Instructor's approach: 4-level quality scale
    CASE
        WHEN RESPONSE_RATE > 95 THEN 'VERY GOOD'
        WHEN RESPONSE_RATE > 80 THEN 'GOOD'
        WHEN RESPONSE_RATE > 60 THEN 'FAIR'
        ELSE 'POOR'
    END                                                         AS RESPONSE_RATE_QUALITY,

    -- Experience level derived from tenure
    CASE
        WHEN DATEDIFF('year', HOST_SINCE, CURRENT_DATE()) < 1  THEN 'NEW'
        WHEN DATEDIFF('year', HOST_SINCE, CURRENT_DATE()) < 3  THEN 'EXPERIENCED'
        ELSE 'VETERAN'
    END                                                         AS HOST_LEVEL,

    CREATED_AT

FROM bronze

WHERE HOST_ID IS NOT NULL