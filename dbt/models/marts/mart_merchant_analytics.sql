SELECT
    merchant_name,
    any(category) AS primary_category,
    count() AS transaction_count,
    countIf(is_fraud = 1) AS fraud_count,
    fraud_count / transaction_count * 100 AS fraud_rate_pct,
    sum(amount) AS turnover,
    sumIf(amount, is_fraud = 1) AS fraud_turnover,
    fraud_rate_pct >= 10 OR fraud_count >= 20 AS is_suspicious
FROM {{ ref('stg_transactions') }}
GROUP BY merchant_name
