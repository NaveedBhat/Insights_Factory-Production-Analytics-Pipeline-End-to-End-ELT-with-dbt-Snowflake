{% macro incremental_filter(column, target_table, lookback_days=1) %}
    {{ column }} >= DATEADD(
        'day',
        -{{ lookback_days }},
        (
            SELECT COALESCE(MAX({{ column }}), '1900-01-01'::TIMESTAMP)
            FROM {{ target_table }}
        )
    )
{% endmacro %}

{#
    Incremental watermark filter with a lookback window.

    Why >= instead of >:
      Catches boundary records with the same timestamp as MAX.

    Why lookback_days (default = 1):
      Re-processes the last N days on every incremental run.
      This catches records whose CREATED_AT is recent but whose other
      columns (e.g. BOOKING_STATUS, PRICE) were updated after the last run.
      unique_key on each model ensures these re-processed rows are
      UPDATED (not duplicated) via Snowflake MERGE.

    Limitation:
      Records older than lookback_days whose columns change are still missed.
      A proper UPDATED_AT column in the source would fully resolve this.

    Usage:
      Default 1-day lookback:  {{ incremental_filter('CREATED_AT', this) }}
      Custom 3-day lookback:   {{ incremental_filter('CREATED_AT', this, 3) }}
#}
