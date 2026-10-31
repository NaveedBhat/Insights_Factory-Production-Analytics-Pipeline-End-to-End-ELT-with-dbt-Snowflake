# Snapshots — SCD Type 2 Dimension Tables

**Location:** `INSIGHTS_FACTORY.GOLD`
**Format:** dbt 1.9+ YML-based snapshot config
**Strategy:** Timestamp-based (detects changes via `updated_at` column)

---

## What Is SCD Type 2?

Slowly Changing Dimensions (SCD Type 2) preserve **full historical records**. When a tracked column changes (e.g., a host becomes a superhost), dbt:

1. **Closes** the old row — sets `dbt_valid_to` to the current timestamp
2. **Inserts** a new row — `dbt_valid_from` = now, `dbt_valid_to` = `9999-12-31`

This lets analysts query what a host looked like at **any point in time**.

---

## Snapshot Definitions

| File | Snapshot Name | Source | Unique Key | Updated At | Rows |
|---|---|---|---|---|---|
| `dim_bookings.yml` | `dim_bookings` | `ref('bookings')` | `BOOKING_ID` | `CREATED_AT` | 5,000 |
| `dim_hosts.yml` | `dim_hosts` | `ref('hosts')` | `HOST_ID` | `HOST_CREATED_AT` | 189 |
| `dim_listings.yml` | `dim_listings` | `ref('listings')` | `LISTING_ID` | `LISTING_CREATED_AT` | 500 |

> The `ref('bookings')`, `ref('hosts')`, `ref('listings')` here point to the **ephemeral models** in `models/gold/ephemeral/`, not the raw staging tables.

---

## dbt-Managed Columns Added to Every Snapshot

| Column | Description |
|---|---|
| `dbt_scd_id` | Surrogate key — unique identifier for each historical row |
| `dbt_updated_at` | When this version was last updated |
| `dbt_valid_from` | When this version became active |
| `dbt_valid_to` | When this version expired (`9999-12-31` = currently active) |

`dbt_valid_to_current` is set to `to_date('9999-12-31')` — current records show a concrete sentinel date instead of `NULL`, simplifying analytical queries:

```sql
-- Query current (active) hosts only:
SELECT * FROM dim_hosts WHERE dbt_valid_to = '9999-12-31';
```

---

## How to Run

```bash
# Run all snapshots
dbt snapshot

# Run a specific snapshot
dbt snapshot --select dim_hosts
```

> Always run `dbt run` before `dbt snapshot` — snapshots read from `ref('obt')` via the ephemeral models.
