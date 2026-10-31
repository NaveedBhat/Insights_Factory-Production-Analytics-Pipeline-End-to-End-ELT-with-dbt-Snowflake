-- SELECT * FROM {{ ref('bronze_bookings') }} 

-- SELECT * FROM {{ ref('bronze_listings') }} 

-- SELECT * FROM {{ ref('bronze_hosts') }} 

-- SELECT * FROM {{ ref('silver_listings') }} 

SELECT * FROM {{ ref('silver_hosts') }} 


