{{ config(materialized='view') }}

WITH cleaned AS (
    SELECT
        transaction_time,
        trim(merch) AS merchant_name,
        lowerUTF8(trim(cat_id)) AS category,
        toFloat64(amount) AS amount,
        trim(name_1) AS first_name,
        trim(name_2) AS last_name,
        upperUTF8(trim(gender)) AS gender,
        trim(street) AS street,
        trim(one_city) AS city,
        upperUTF8(trim(us_state)) AS state,
        trim(post_code) AS postal_code,
        toFloat64(lat) AS customer_latitude,
        toFloat64(lon) AS customer_longitude,
        toFloat64(merchant_lat) AS merchant_latitude,
        toFloat64(merchant_lon) AS merchant_longitude,
        toUInt8(target) AS is_fraud,
        concat(
            lowerUTF8(trim(name_1)), '|', lowerUTF8(trim(name_2)), '|',
            trim(post_code), '|', lowerUTF8(trim(street))
        ) AS customer_key
    FROM {{ source('transactions_db', 'transactions') }}
)
SELECT
    *,
    toDate(transaction_time) AS transaction_date,
    toHour(transaction_time) AS transaction_hour,
    toDayOfWeek(transaction_time) AS day_of_week,
    {{ dbt_date.day_name('transaction_time') }} AS day_name,
    {{ amount_bucket('amount') }} AS amount_segment
FROM cleaned
