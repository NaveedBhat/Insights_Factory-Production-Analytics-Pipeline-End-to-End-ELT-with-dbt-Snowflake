{# -- USING JIJA TO MAKE IT DYNMIC
{% set nights_booked = 3 %}

SELECT * FROM {{ ref('bronze_bookings') }}

WHERE NIGHTS_BOOKED > {{ nights_booked }}
WHERE NIGHTS_BOOKED > 3 -- THIS IS HARDCODED NOW LETS USE JINJA TO MAKE IT DYNAMIC #}

-- Other Exmaple of if else
{% set flag = 2 %}

SELECT * FROM {{ ref('bronze_bookings') }}
{% if flag  == 1 %}
   WHERE NIGHTS_BOOKED > 1
{% else %}
   WHERE NIGHTS_BOOKED = 1
{% endif %}

