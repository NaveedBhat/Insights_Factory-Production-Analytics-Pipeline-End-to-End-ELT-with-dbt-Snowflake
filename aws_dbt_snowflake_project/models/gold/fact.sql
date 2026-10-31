{{
    config(
        materialized = 'table',
        schema = 'gold'
    )
}}

{#
    Metadata-driven FACT table — instructor pattern
    Joins OBT (measures + FKs) against SCD2 dimension snapshots.
    Columns are selected only from OBT; dims are joined for FK validation.
    To add a new dim join: add a dict to configs — zero SQL change needed.

    Improvement over instructor's version:
      ref() used instead of hardcoded INSIGHTS_FACTORY.GOLD.* paths
      → preserves DAG lineage and works across environments (dev/prod)
#}

-- THIS IS A FACT TABLE AND HERE WE PUT ONLY NUMERIC DATA LIKE NUMBERS 

{% set configs = [
    {
        "table"  : ref('obt'),
        "columns": "obt.BOOKING_ID,
                    obt.LISTING_ID,
                    obt.HOST_ID,
                    obt.TOTAL_AMOUNT,
                    obt.SERVICE_FEE,
                    obt.CLEANING_FEE,
                    obt.ACCOMMODATES,
                    obt.BEDROOMS,
                    obt.BATHROOMS,
                    obt.PRICE_PER_NIGHT,
                    obt.RESPONSE_RATE",
        "alias"  : "obt"
    },
    {
        "table"         : ref('dim_listings'),
        "columns"       : "",
        "alias"         : "dim_listings",
        "join_condition": "obt.LISTING_ID = dim_listings.LISTING_ID"
    },
    {
        "table"         : ref('dim_hosts'),
        "columns"       : "",
        "alias"         : "dim_hosts",
        "join_condition": "obt.HOST_ID = dim_hosts.HOST_ID"
    }
] %}

SELECT
    {{ configs[0]['columns'] }}

FROM
    {% for config in configs %}
        {% if loop.first %}
            {{ config['table'] }} AS {{ config['alias'] }}
        {% else %}
            LEFT JOIN {{ config['table'] }} AS {{ config['alias'] }}
                ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
