# Analyses — Compiled SQL Explorations

dbt compiles files in `analyses/` and validates their Jinja/SQL syntax — but **never executes them**. They are useful for learning, prototyping, and ad-hoc exploration without accidentally modifying the warehouse.

---

## Files

| File | Purpose |
|---|---|
| `for_loop.sql` | Demonstrates Jinja `{% for %}` loop to dynamically build a SELECT column list |
| `if_else.sql` | Demonstrates Jinja `{% if %}` / `{% else %}` for dynamic WHERE clause injection |
| `test.sql` | Ad-hoc exploration queries against silver and gold models |

---

## How Analyses Work

```bash
# Compile all analyses (validates SQL without running)
dbt compile

# Compiled output is written to:
# target/compiled/aws_dbt_snowflake_project/analyses/
```

You can copy the compiled SQL from `target/compiled/` and run it manually in Snowflake whenever needed.

---

## Example — `for_loop.sql`

Demonstrates generating a SELECT list dynamically from a Jinja list:

```sql
{% set columns = ['BOOKING_ID', 'BOOKING_DATE', 'TOTAL_AMOUNT'] %}

SELECT
    {% for col in columns %}
        {{ col }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM {{ ref('silver_bookings') }}
```

---

## Example — `if_else.sql`

Demonstrates injecting a WHERE clause conditionally:

```sql
{% set filter_confirmed = true %}

SELECT * FROM {{ ref('silver_bookings') }}
{% if filter_confirmed %}
    WHERE IS_CONFIRMED = TRUE
{% else %}
    WHERE 1 = 1
{% endif %}
```

---

> Analyses do not appear in the dbt DAG and have no impact on any Snowflake objects. They are purely a learning and exploration tool.
