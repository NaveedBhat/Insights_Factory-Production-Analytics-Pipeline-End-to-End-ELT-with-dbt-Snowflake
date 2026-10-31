# Gold Layer — Analytics-Ready Tables

**Schema:** `INSIGHTS_FACTORY.GOLD`
**Purpose:** Deliver analytics-ready data in two forms — a wide denormalized OBT for flexible querying, and a normalised Star Schema for dimensional analytics.

---

## Models Overview

| Model | Type | Rows | Description |
|---|---|---|---|
| `obt.sql` | Table | 5,000 | One Big Table — 3-way JOIN across all silver models, 34 columns |
| `fact.sql` | Table | 5,000 | Fact table — measures + FK columns from OBT, joined to SCD2 dims |
| `ephemeral/` | Ephemeral | — | Inline CTEs that feed the SCD2 snapshot inputs |

---

## `obt.sql` — One Big Table

**Materialization:** `table` (full rebuild on every `dbt run`)
**Columns:** 34 (12 from `silver_bookings.*` + 14 from `silver_listings` explicit + 8 from `silver_hosts` explicit)

Built using a **metadata-driven Jinja pattern** — tables, columns, and join conditions are defined in a `configs` list. Adding a new source table requires zero SQL changes — just add a new dict to the list.

```
silver_bookings  (base)
  LEFT JOIN silver_listings  ON LISTING_ID
    LEFT JOIN silver_hosts   ON HOST_ID
```

---

## `fact.sql` — Fact Table

**Materialization:** `table`
**Columns selected:** `BOOKING_ID, LISTING_ID, HOST_ID, TOTAL_AMOUNT, SERVICE_FEE, CLEANING_FEE, ACCOMMODATES, BEDROOMS, BATHROOMS, PRICE_PER_NIGHT, RESPONSE_RATE`

Joins `obt` against `dim_listings` and `dim_hosts` SCD2 snapshots for FK validation. Also metadata-driven — dims are added via config dicts, not raw SQL.

---

## `ephemeral/` Subfolder

Contains three ephemeral models that act as clean, deduplicated inputs to the SCD2 snapshots:

| File | Feeds | Uses DISTINCT |
|---|---|---|
| `bookings.sql` | `dim_bookings` | No |
| `hosts.sql` | `dim_hosts` | Yes — deduplicates hosts across bookings |
| `listings.sql` | `dim_listings` | Yes — deduplicates listings across bookings |

Ephemeral models are **never materialized in Snowflake** — they compile as inline CTEs inside the snapshot queries.

---

## Snowflake Objects Created

```
INSIGHTS_FACTORY.GOLD
  ├── OBT              ← Table (5,000 rows · 34 columns)
  ├── DIM_BOOKINGS     ← SCD2 snapshot (5,000 rows)
  ├── DIM_HOSTS        ← SCD2 snapshot (189 unique hosts)
  ├── DIM_LISTINGS     ← SCD2 snapshot (500 rows)
  └── FACT             ← Table (5,000 rows · 11 columns)
```

> `DIM_*` tables are created by `dbt snapshot`, not `dbt run`. Run `dbt snapshot` after `dbt run`.
