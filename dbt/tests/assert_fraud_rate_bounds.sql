SELECT 'mart_fraud_by_category' AS model_name, category AS entity, fraud_rate_pct
FROM {{ ref('mart_fraud_by_category') }}
WHERE fraud_rate_pct < 0 OR fraud_rate_pct > 100

UNION ALL

SELECT 'mart_fraud_by_state', state, fraud_rate_pct
FROM {{ ref('mart_fraud_by_state') }}
WHERE fraud_rate_pct < 0 OR fraud_rate_pct > 100

UNION ALL

SELECT 'mart_hourly_fraud_pattern', concat(toString(day_of_week), '-', toString(transaction_hour)), fraud_rate_pct
FROM {{ ref('mart_hourly_fraud_pattern') }}
WHERE fraud_rate_pct < 0 OR fraud_rate_pct > 100
