# Ephemeral Models — Snapshot Input CTEs

**Materialization:** `ephemeral` (never written to Snowflake)
**Purpose:** Provide clean, deduplicated input rows to the SCD Type 2 snapshot definitions in `snapshots/`.

---

## Why Ephemeral?

The OBT (`gold/obt.sql`) contains **one row per booking**. A host with 50 bookings appears 50 times. Without deduplication, feeding the OBT directly into a snapshot would fail the `unique_key` constraint.

Ephemeral models solve this cleanly:
- No intermediate Snowflake table is created (saves cost + pipeline steps)
- They compile as **inline CTEs** directly inside the snapshot SQL
- `SELECT DISTINCT` collapses duplicate host/listing rows to one per entity

---

## Models

### `bookings.sql`
Selects `BOOKING_ID, BOOKING_DATE, BOOKING_STATUS, CREATED_AT` from `ref('obt')`.
No `DISTINCT` needed — each booking already appears once.
→ Feeds `snapshots/dim_bookings.yml`

### `hosts.sql`
`SELECT DISTINCT HOST_ID, HOST_NAME, HOST_SINCE, IS_SUPERHOST, RESPONSE_RATE_QUALITY, HOST_CREATED_AT` from `ref('obt')`.
→ Feeds `snapshots/dim_hosts.yml`

### `listings.sql`
`SELECT DISTINCT LISTING_ID, PROPERTY_TYPE, ROOM_TYPE, CITY, COUNTRY, PRICE_CATEGORY, LISTING_CREATED_AT` from `ref('obt')`.
→ Feeds `snapshots/dim_listings.yml`

---

## DAG Position

```
silver_bookings ──┐
silver_listings ──┼──► OBT ──► ephemeral/bookings ──► dim_bookings (snapshot)
silver_hosts    ──┘      │
                         ├──► ephemeral/hosts    ──► dim_hosts    (snapshot)
                         ├──► ephemeral/listings ──► dim_listings (snapshot)
                         └──► fact (table)
```

> These models have no schema or database config — materialization is set to `ephemeral` in `dbt_project.yml` under the `gold.ephemeral` path.
