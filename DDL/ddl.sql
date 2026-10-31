-- =============================================================
-- DDL — Source Table Definitions
-- Database: INSIGHTS_FACTORY
-- Schema:   STAGING
-- =============================================================
-- Run these once in Snowflake to create the raw source tables.
-- Data is loaded from S3 via the COPY INTO commands in resources.sql
-- =============================================================

USE DATABASE INSIGHTS_FACTORY;
USE SCHEMA STAGING;

-- -------------------------------------------------------------
-- HOSTS — One row per host
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE HOSTS (
    host_id       NUMBER,
    host_name     STRING,
    host_since    DATE,
    is_superhost  BOOLEAN,
    response_rate NUMBER,
    created_at    TIMESTAMP,
    PRIMARY KEY (host_id)
);

-- -------------------------------------------------------------
-- LISTINGS — One row per property listing
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE LISTINGS (
    listing_id      NUMBER,
    host_id         NUMBER,
    property_type   STRING,
    room_type       STRING,
    city            STRING,
    country         STRING,
    accommodates    NUMBER,
    bedrooms        NUMBER,
    bathrooms       NUMBER,
    price_per_night NUMBER,
    created_at      TIMESTAMP,
    PRIMARY KEY (listing_id)
);

-- -------------------------------------------------------------
-- BOOKINGS — One row per booking transaction
-- -------------------------------------------------------------
CREATE OR REPLACE TABLE BOOKINGS (
    booking_id     STRING,
    listing_id     NUMBER,
    booking_date   TIMESTAMP,
    nights_booked  NUMBER,
    booking_amount NUMBER,
    cleaning_fee   NUMBER,
    service_fee    NUMBER,
    booking_status STRING,
    created_at     TIMESTAMP,
    PRIMARY KEY (booking_id)
);
