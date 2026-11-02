SELECT
    state,
    count() AS transaction_count,
    countIf(is_fraud = 1) AS fraud_count,
    fraud_count / transaction_count * 100 AS fraud_rate_pct,
    uniqExact(customer_key) AS unique_customers,
    uniqExact(merchant_name) AS unique_merchants,
    sum(amount) AS total_amount,
    sumIf(amount, is_fraud = 1) AS fraud_amount
FROM {{ ref('stg_transactions') }}
GROUP BY state
