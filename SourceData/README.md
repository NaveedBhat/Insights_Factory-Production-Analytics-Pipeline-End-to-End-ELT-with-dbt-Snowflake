# SourceData — Raw CSV Source Files

This folder contains the **raw source data** that powers the entire pipeline. These files are uploaded to AWS S3, then loaded into Snowflake `STAGING` via the scripts in `DDL/resources.sql`.

---

## Files

| File | Records | Description |
|---|---|---|
| `bookings.csv` | 5,000 | Individual booking transactions — booking ID, listing, dates, amounts, status |
| `hosts.csv` | 200 | Host profiles — name, tenure, superhost flag, response rate |
| `listings.csv` | 500 | Property listings — location, type, capacity, pricing |

---

## Schema

### `bookings.csv`
| Column | Type | Description |
|---|---|---|
| `booking_id` | STRING | Unique booking identifier (UUID) |
| `listing_id` | NUMBER | Foreign key → listings |
| `booking_date` | TIMESTAMP | Date the stay occurred |
| `nights_booked` | NUMBER | Duration of stay |
| `booking_amount` | NUMBER | Base stay cost |
| `cleaning_fee` | NUMBER | Optional cleaning charge |
| `service_fee` | NUMBER | Optional service charge |
| `booking_status` | STRING | `confirmed` / `cancelled` / `pending` |
| `created_at` | TIMESTAMP | Record creation timestamp |

### `hosts.csv`
| Column | Type | Description |
|---|---|---|
| `host_id` | NUMBER | Unique host identifier |
| `host_name` | STRING | Host display name |
| `host_since` | DATE | Date host joined the platform |
| `is_superhost` | BOOLEAN | Superhost status flag |
| `response_rate` | NUMBER | Response rate percentage (0–100) |
| `created_at` | TIMESTAMP | Record creation timestamp |

### `listings.csv`
| Column | Type | Description |
|---|---|---|
| `listing_id` | NUMBER | Unique listing identifier |
| `host_id` | NUMBER | Foreign key → hosts |
| `property_type` | STRING | e.g. Apartment, House, Villa |
| `room_type` | STRING | e.g. Entire home/apt, Private room |
| `city` | STRING | City of the listing |
| `country` | STRING | Country of the listing |
| `accommodates` | NUMBER | Max number of guests |
| `bedrooms` | NUMBER | Number of bedrooms |
| `bathrooms` | NUMBER | Number of bathrooms |
| `price_per_night` | NUMBER | Advertised nightly rate |
| `created_at` | TIMESTAMP | Record creation timestamp |

---

## Data Pipeline Position

```
SourceData/ (CSV)
    → S3 Bucket (snowbucketnavii/source/)
        → Snowflake STAGING (via COPY INTO in DDL/resources.sql)
            → dbt Bronze Layer (incremental passthrough)
                → dbt Silver Layer (enrichment + business logic)
                    → dbt Gold Layer (OBT + Star Schema)
```

> These files are committed here as a reference mirror of what lives in S3. The authoritative source for the pipeline is the S3 bucket.
