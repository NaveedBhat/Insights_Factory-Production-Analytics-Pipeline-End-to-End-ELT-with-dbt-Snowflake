# DDL — Snowflake Setup Scripts

This folder contains the **one-time setup scripts** that must be run in Snowflake **before** executing the dbt pipeline.

---

## Files

| File | Purpose |
|---|---|
| `ddl.sql` | Creates the three raw source tables inside `INSIGHTS_FACTORY.STAGING` |
| `resources.sql` | Creates the S3 file format, external stage, and loads data via `COPY INTO` |

---

## Execution Order

```
1. ddl.sql        → Creates STAGING.BOOKINGS, STAGING.HOSTS, STAGING.LISTINGS
2. resources.sql  → Loads CSV data from S3 into those tables
```

Run both scripts **once** directly in the Snowflake UI (Worksheets) before running `dbt run`.

---

## What `ddl.sql` Creates

| Table | Schema | Primary Key | Rows |
|---|---|---|---|
| `BOOKINGS` | `STAGING` | `BOOKING_ID` | 5,000 |
| `HOSTS` | `STAGING` | `HOST_ID` | 200 |
| `LISTINGS` | `STAGING` | `LISTING_ID` | 500 |

---

## What `resources.sql` Does

1. Creates a `csv_format` file format (comma-delimited, skip header)
2. Creates a `snowstage` external stage pointing to the S3 bucket (`s3://snowbucketnavii/source/`)
3. Runs `COPY INTO` for all three tables
4. Verifies row counts

> ⚠️ **Security:** `resources.sql` contains `<YOUR_AWS_KEY_ID>` and `<YOUR_AWS_SECRET_KEY>` placeholders.
> Fill these in **only inside Snowflake's worksheet UI** — never commit real credentials to version control.

---

## Snowflake Context

```sql
USE DATABASE INSIGHTS_FACTORY;
USE SCHEMA STAGING;
```

After running both scripts, the dbt pipeline (`aws_dbt_snowflake_project/`) takes over and transforms this raw data through Bronze → Silver → Gold.
