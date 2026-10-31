# Sources — Staging Source Declarations

**File:** `sources.yml`
**Purpose:** Declares the raw `INSIGHTS_FACTORY.STAGING` tables as dbt sources, enabling `source()` references and source-level data tests.

---

## Why Use `source()` Instead of Hardcoding?

Using `source('staging', 'bookings')` instead of `INSIGHTS_FACTORY.STAGING.BOOKINGS` gives:

- ✅ **Source freshness checks** — dbt can alert if source data stops updating
- ✅ **Lineage tracking** — dbt DAG correctly shows `STAGING → BRONZE` dependencies
- ✅ **Centralized config** — change database/schema in one place, not every model
- ✅ **Source tests** — `unique` and `not_null` on raw tables before any transformation runs

---

## Declared Sources

| Source Name | Database | Schema | Tables |
|---|---|---|---|
| `staging` | `INSIGHTS_FACTORY` | `staging` | `bookings`, `listings`, `hosts` |

---

## Source Tests (6 total)

| Table | Column | Tests |
|---|---|---|
| `bookings` | `BOOKING_ID` | `unique`, `not_null` |
| `listings` | `LISTING_ID` | `unique`, `not_null` |
| `hosts` | `HOST_ID` | `unique`, `not_null` |

Run with: `dbt test --select source:staging`

---

## Usage in Bronze Models

```sql
-- bronze_bookings.sql
SELECT * FROM {{ source('staging', 'bookings') }}
```

The `source()` function resolves to `INSIGHTS_FACTORY.staging.bookings` at compile time.
