# Bronze Layer — Incremental Pass-Through Models

**Schema:** `INSIGHTS_FACTORY.BRONZE`
**Materialization:** Incremental (Snowflake MERGE upsert)
**Purpose:** Ingest raw source data from `STAGING` into the warehouse with minimal transformation. The Bronze layer is the first landing zone for dbt-managed data.

---

## Models

| Model | Source Table | Unique Key | Incremental Filter |
|---|---|---|---|
| `bronze_bookings.sql` | `STAGING.BOOKINGS` | `BOOKING_ID` | `CREATED_AT` |
| `bronze_listings.sql` | `STAGING.LISTINGS` | `LISTING_ID` | `CREATED_AT` |
| `bronze_hosts.sql` | `STAGING.HOSTS` | `HOST_ID` | `CREATED_AT` |

---

## How It Works

- **First run:** Full load — all rows from `STAGING` are copied to `BRONZE`
- **Subsequent runs:** Only records newer than `MAX(CREATED_AT) - 1 day` are processed
- **Upsert strategy:** Snowflake MERGE — if `BOOKING_ID` already exists → UPDATE, otherwise → INSERT
- **Incremental filter:** Uses the custom `incremental_filter('CREATED_AT', this)` macro

```sql
{% if is_incremental() %}
    WHERE {{ incremental_filter('CREATED_AT', this) }}
{% endif %}
```

---

## Design Decisions

- **No transformations** — Bronze is a faithful copy of source data. All business logic lives in Silver.
- **`unique_key`** — Enables idempotent upserts. Running the pipeline twice produces the same result.
- **1-day lookback** — Re-processes the last day on every run to catch records that arrived late or were updated after the last pipeline execution.

---

## What's Not Here

`properties.yml` in this folder contains no active test configuration — all data tests are managed at the parent level in `models/properties.yml`. Schema and materialization config is set in `dbt_project.yml`.
