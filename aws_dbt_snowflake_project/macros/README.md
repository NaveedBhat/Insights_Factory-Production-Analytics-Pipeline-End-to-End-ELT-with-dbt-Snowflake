# Macros — Custom Jinja-SQL Functions

All macros are reusable Jinja functions that compile into standard SQL at runtime. They are available to every model, snapshot, and analysis in the project.

---

## Macros

### `generate_schema_name(custom_schema_name, node)`
**File:** `generate_schema_name.sql`

Overrides dbt's default schema naming behavior. Without this macro, dbt prepends the target schema to custom schema names:

```
❌ Default:  INSIGHTS_FACTORY.dbt_schema_bronze.bronze_bookings
✅ Override: INSIGHTS_FACTORY.BRONZE.bronze_bookings
```

This macro returns the `custom_schema_name` as-is when one is provided, giving clean schema names: `BRONZE`, `SILVER`, `GOLD`.

---

### `incremental_filter(column, target_table, lookback_days=1)`
**File:** `incremental_filter.sql`

Watermark-based incremental filter. Finds `MAX(column)` in the existing table and filters to records newer than `MAX - lookback_days`.

```sql
-- Usage in a model:
WHERE {{ incremental_filter('CREATED_AT', this) }}

-- Compiles to:
WHERE CREATED_AT >= DATEADD('day', -1,
    (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01'::TIMESTAMP) FROM <this_model>)
)
```

The 1-day lookback re-processes recent records on every run, catching rows that were updated after the last pipeline execution. Combined with `unique_key`, Snowflake MERGE handles duplicates automatically.

---

### `safe_divide(numerator, denominator)`
**File:** `safe_divide.sql`

Wraps division in `NULLIF(denominator, 0)` to prevent divide-by-zero errors.

```sql
-- Usage:
{{ safe_divide('BOOKING_AMOUNT', 'NIGHTS_BOOKED') }}

-- Compiles to:
(BOOKING_AMOUNT / NULLIF(NIGHTS_BOOKED, 0))
```

Returns `NULL` when denominator is zero instead of raising a SQL error.

---

### `tag(column_name, low, high)`
**File:** `tag.sql`

3-level categorical tagger. Classifies numeric values into `LOW / MEDIUM / HIGH` bands.

```sql
-- Usage:
{{ tag('PRICE_PER_NIGHT', 100, 200) }} AS PRICE_CATEGORY

-- Compiles to:
CASE
    WHEN PRICE_PER_NIGHT < 100              THEN 'LOW'
    WHEN PRICE_PER_NIGHT BETWEEN 100 AND 200 THEN 'MEDIUM'
    WHEN PRICE_PER_NIGHT > 200              THEN 'HIGH'
    ELSE 'UNKNOWN'
END AS PRICE_CATEGORY
```

---

### `trimmer(column_name)`
**File:** `trimmer.sql`

Applies `UPPER(TRIM())` to standardise string data at SQL runtime.

```sql
-- Usage:
{{ trimmer('BOOKING_STATUS') }} AS BOOKING_STATUS

-- Compiles to:
UPPER(TRIM(BOOKING_STATUS)) AS BOOKING_STATUS
```

Used on `BOOKING_STATUS`, `PROPERTY_TYPE`, `ROOM_TYPE`, `CITY`, `COUNTRY`, `HOST_NAME`.

> **Note:** Jinja pipe filters (`| trim | upper`) only transform the column *name string* at compile time, not the actual data values. SQL functions are required for runtime data transformation.
