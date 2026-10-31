# Silver Layer — Enriched & Business-Logic Models

**Schema:** `INSIGHTS_FACTORY.SILVER`
**Materialization:** Incremental (Snowflake MERGE upsert)
**Purpose:** Apply business logic, data type casting, data quality flags, and derived columns. Silver is where raw data becomes trusted, analysis-ready data.

---

## Models

| Model | Key Derived Columns | Unique Key |
|---|---|---|
| `silver_bookings.sql` | `TOTAL_AMOUNT`, `EFFECTIVE_NIGHTLY_RATE`, `IS_CONFIRMED` | `BOOKING_ID` |
| `silver_listings.sql` | `PRICE_CATEGORY`, `IS_ENTIRE_HOME`, `CAPACITY_CATEGORY`, `PRICE_PER_PERSON` | `LISTING_ID` |
| `silver_hosts.sql` | `RESPONSE_RATE_QUALITY`, `YEARS_AS_HOST`, `HOST_LEVEL` | `HOST_ID` |

---

## Transformations Applied

### `silver_bookings`
| Column | Logic |
|---|---|
| `BOOKING_STATUS` | `trimmer()` macro → `UPPER(TRIM(...))` |
| `TOTAL_AMOUNT` | `BOOKING_AMOUNT + COALESCE(CLEANING_FEE,0) + COALESCE(SERVICE_FEE,0)` |
| `EFFECTIVE_NIGHTLY_RATE` | `safe_divide(BOOKING_AMOUNT, NIGHTS_BOOKED)` — protected against zero denominator |
| `IS_CONFIRMED` | `TRUE` if `BOOKING_STATUS = 'CONFIRMED'` |

### `silver_listings`
| Column | Logic |
|---|---|
| `PROPERTY_TYPE`, `ROOM_TYPE`, `CITY`, `COUNTRY` | `trimmer()` macro — cleaned |
| `PRICE_CATEGORY` | `tag(PRICE_PER_NIGHT, 100, 200)` → `LOW / MEDIUM / HIGH` |
| `IS_ENTIRE_HOME` | `TRUE` if `ROOM_TYPE = 'ENTIRE HOME/APT'` |
| `CAPACITY_CATEGORY` | `SOLO/COUPLE / SMALL GROUP / LARGE GROUP / BULK` based on `ACCOMMODATES` |
| `PRICE_PER_PERSON` | `safe_divide(PRICE_PER_NIGHT, ACCOMMODATES)` |

### `silver_hosts`
| Column | Logic |
|---|---|
| `HOST_NAME` | `trimmer()` macro — cleaned |
| `YEARS_AS_HOST` | `DATEDIFF('year', HOST_SINCE, CURRENT_DATE())` |
| `RESPONSE_RATE_QUALITY` | 4-level CASE: `VERY GOOD / GOOD / FAIR / POOR` based on `RESPONSE_RATE` |
| `HOST_LEVEL` | `NEW / EXPERIENCED / VETERAN` based on `YEARS_AS_HOST` |

---

## Key Design Note

`PRICE_PER_NIGHT` in `silver_bookings` is renamed to **`EFFECTIVE_NIGHTLY_RATE`**. This avoids a duplicate column name collision when `obt.sql` uses `silver_bookings.*` and explicitly selects `silver_listings.PRICE_PER_NIGHT` in the same query.

---

## Macros Used

| Macro | Used In |
|---|---|
| `trimmer(column)` | All three models |
| `safe_divide(n, d)` | `silver_bookings`, `silver_listings` |
| `tag(col, low, high)` | `silver_listings` |
| `incremental_filter(col, this)` | All three models |
