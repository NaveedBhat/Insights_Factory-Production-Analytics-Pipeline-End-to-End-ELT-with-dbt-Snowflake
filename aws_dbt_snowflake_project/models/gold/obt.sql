{{ config(materialized = 'table') }}

{#
    METADATA-DRIVEN OBT (One Big Table)
    ─────────────────────────────────────────────────────────────────────────────
    Instructor's pattern: columns as a raw SQL string (simpler, supports aliases)
    Our improvement:      ref() instead of hardcoded paths (proper DAG lineage)

    To add a new table: add a dict to configs. Zero SQL code changes needed.
    ─────────────────────────────────────────────────────────────────────────────
#}

{% set configs = [
    {
        "table"  : ref('silver_bookings'),
        "columns": "silver_bookings.*",
        "alias"  : "silver_bookings"
    },
    {
        "table"  : ref('silver_listings'),
        "columns": "silver_listings.HOST_ID,
                    silver_listings.PROPERTY_TYPE,
                    silver_listings.ROOM_TYPE,
                    silver_listings.CITY,
                    silver_listings.COUNTRY,
                    silver_listings.ACCOMMODATES,
                    silver_listings.BEDROOMS,
                    silver_listings.BATHROOMS,
                    silver_listings.PRICE_PER_NIGHT,
                    silver_listings.PRICE_CATEGORY,
                    silver_listings.IS_ENTIRE_HOME,
                    silver_listings.CAPACITY_CATEGORY,
                    silver_listings.PRICE_PER_PERSON,
                    silver_listings.CREATED_AT  AS LISTING_CREATED_AT",
        "alias"         : "silver_listings",
        "join_condition": "silver_bookings.LISTING_ID = silver_listings.LISTING_ID"
    },
    {
        "table"  : ref('silver_hosts'),
        "columns": "silver_hosts.HOST_NAME,
                    silver_hosts.HOST_SINCE,
                    silver_hosts.IS_SUPERHOST,
                    silver_hosts.RESPONSE_RATE,
                    silver_hosts.RESPONSE_RATE_QUALITY,
                    silver_hosts.YEARS_AS_HOST,
                    silver_hosts.HOST_LEVEL,
                    silver_hosts.CREATED_AT  AS HOST_CREATED_AT",
        "alias"         : "silver_hosts",
        "join_condition": "silver_listings.HOST_ID = silver_hosts.HOST_ID"
    }
] %}

-- Its a matadata driven pipeline and with the help of this we dont need to do anthing in code if we have to add anything we can do it on configs no need to touch below code
-- THIS IS METADATA DRIEN PIPELINE USING DBT AND JINJA AND CONFIGS
SELECT
    {% for config in configs %}
        {{ config['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}

FROM
    {% for config in configs %}
        {% if loop.first %}
            {{ config['table'] }} AS {{ config['alias'] }}
        {% else %}
            LEFT JOIN {{ config['table'] }} AS {{ config['alias'] }}
                ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
