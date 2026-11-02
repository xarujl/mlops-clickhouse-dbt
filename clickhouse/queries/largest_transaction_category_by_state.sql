-- Для каждого штата выводим категорию самой крупной отдельной транзакции.
-- Дополнительные поля задают стабильный порядок, если суммы совпали.
SELECT
    us_state,
    cat_id AS largest_transaction_category,
    amount AS largest_transaction_amount,
    transaction_time,
    merch
FROM transactions_db.transactions
QUALIFY row_number() OVER (
    PARTITION BY us_state
    ORDER BY amount DESC, transaction_time, merch, cat_id
) = 1
ORDER BY us_state;
