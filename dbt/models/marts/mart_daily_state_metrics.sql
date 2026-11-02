SELECT
    transaction_date,
    state,
    count() AS transaction_count,
    sum(amount) AS total_amount,
    avg(amount) AS average_ticket,
    quantile(0.95)(amount) AS p95_amount,
    countIf(amount >= 500) / count() * 100 AS large_transaction_pct
FROM {{ ref('stg_transactions') }}
GROUP BY transaction_date, state
