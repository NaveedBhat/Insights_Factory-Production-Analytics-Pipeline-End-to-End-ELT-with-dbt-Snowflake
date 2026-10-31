-- =============================================================
-- resources.sql — Snowflake External Stage Setup & Data Load
-- =============================================================
-- Prerequisites:
--   1. INSIGHTS_FACTORY database and STAGING schema must exist
--   2. Run ddl.sql first to create the target tables
--   3. Replace <YOUR_AWS_KEY_ID> and <YOUR_AWS_SECRET_KEY>
--      with your actual AWS IAM credentials (never commit real keys)
-- =============================================================

USE DATABASE INSIGHTS_FACTORY;
USE SCHEMA STAGING;

-- -------------------------------------------------------------
-- Step 1 — Create CSV file format
-- -------------------------------------------------------------
CREATE FILE FORMAT IF NOT EXISTS csv_format
    TYPE                        = 'CSV'
    FIELD_DELIMITER             = ','
    SKIP_HEADER                 = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

SHOW FILE FORMATS;

-- -------------------------------------------------------------
-- Step 2 — Create external stage pointing to S3 source bucket
-- Replace credentials with your own AWS IAM key pair
-- -------------------------------------------------------------
CREATE OR REPLACE STAGE snowstage
    URL         = 's3://snowbucketnavii/source/'
    CREDENTIALS = (
        AWS_KEY_ID     = '<YOUR_AWS_KEY_ID>'
        AWS_SECRET_KEY = '<YOUR_AWS_SECRET_KEY>'
    )
    FILE_FORMAT = csv_format;

SHOW STAGES;

-- -------------------------------------------------------------
-- Step 3 — Verify stage access (should list 3 CSV files)
-- -------------------------------------------------------------
LIST @snowstage;

-- -------------------------------------------------------------
-- Step 4 — Load source data from S3 into STAGING tables
-- -------------------------------------------------------------
COPY INTO BOOKINGS
    FROM        @snowstage
    FILES       = ('bookings.csv')
    FILE_FORMAT = (FORMAT_NAME = 'csv_format')
    ON_ERROR    = 'CONTINUE';

COPY INTO HOSTS
    FROM        @snowstage
    FILES       = ('hosts.csv')
    FILE_FORMAT = (FORMAT_NAME = 'csv_format')
    ON_ERROR    = 'CONTINUE';

COPY INTO LISTINGS
    FROM        @snowstage
    FILES       = ('listings.csv')
    FILE_FORMAT = (FORMAT_NAME = 'csv_format')
    ON_ERROR    = 'CONTINUE';

-- -------------------------------------------------------------
-- Step 5 — Verify row counts
-- -------------------------------------------------------------
SELECT COUNT(*) AS bookings_count FROM BOOKINGS;   -- expect 5,000
SELECT COUNT(*) AS hosts_count    FROM HOSTS;       -- expect 200
SELECT COUNT(*) AS listings_count FROM LISTINGS;    -- expect 500

-- -------------------------------------------------------------
-- Step 6 — Quick preview
-- -------------------------------------------------------------
SELECT * FROM BOOKINGS  LIMIT 5;
SELECT * FROM LISTINGS  LIMIT 5;
SELECT * FROM HOSTS     LIMIT 5;
