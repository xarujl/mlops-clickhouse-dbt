WITH customer_metrics AS (
    SELECT
        customer_key,
        any(first_name) AS first_name,
        any(last_name) AS last_name,
        any(state) AS state,
        count() AS transaction_count,
        countIf(is_fraud = 1) AS fraud_count,
        fraud_count / transaction_count * 100 AS fraud_rate_pct,
        avg(amount) AS average_ticket,
        sum(amount) AS total_amount,
        min(transaction_time) AS first_transaction_at,
        max(transaction_time) AS last_transaction_at
    FROM {{ ref('stg_transactions') }}
    GROUP BY customer_key
)
SELECT
    *,
    multiIf(fraud_rate_pct >= 20, 'HIGH', fraud_rate_pct >= 5, 'MEDIUM', 'LOW') AS risk_level
FROM customer_metrics
