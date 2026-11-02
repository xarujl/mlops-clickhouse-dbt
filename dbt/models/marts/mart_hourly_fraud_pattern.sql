SELECT
    day_of_week,
    day_name,
    transaction_hour,
    count() AS transaction_count,
    countIf(is_fraud = 1) AS fraud_count,
    fraud_count / transaction_count * 100 AS fraud_rate_pct,
    avg(amount) AS average_ticket
FROM {{ ref('stg_transactions') }}
GROUP BY day_of_week, day_name, transaction_hour
