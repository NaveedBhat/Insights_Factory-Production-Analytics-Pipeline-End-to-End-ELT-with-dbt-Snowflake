{% macro tag(column_name, low, high) %}
    CASE
        WHEN {{ column_name }} < {{ low }}                        THEN 'LOW'
        WHEN {{ column_name }} BETWEEN {{ low }} AND {{ high }}   THEN 'MEDIUM'
        WHEN {{ column_name }} > {{ high }}                       THEN 'HIGH'
        ELSE 'UNKNOWN'
    END
{% endmacro %}
