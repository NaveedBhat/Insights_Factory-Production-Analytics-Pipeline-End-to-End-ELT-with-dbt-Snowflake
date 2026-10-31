{% macro trimmer(column_name, node=none) %}
    UPPER(TRIM({{ column_name }}))
{% endmacro %}

{#
    Applies two SQL transformations to column DATA at runtime:
    1. TRIM  → removes leading/trailing whitespace from values
    2. UPPER → converts values to uppercase

    Usage:    {{ trimmer('PROPERTY_TYPE') }}
    Compiles: UPPER(TRIM(PROPERTY_TYPE))

    Note: Jinja pipe filters (| trim | upper) only transform the column
    NAME string at compile time, NOT the actual data. SQL functions are needed.
#}
