# ClickHouse и dbt

Сначала загружаем `train.csv` через Kafka в ClickHouse, затем аналитика на dbt. Команды ниже выполняются из корня репозитория.

## Kafka и ClickHouse

1. Запустите сервисы:

   ```bash
   docker compose up -d
   docker compose ps
   ```

2. Установите библиотеку Kafka-продюсера и опубликуйте CSV. Скрипт читает CSV и отправляет каждую запись в Kafka как JSON. ClickHouse читает формат `JSONEachRow`.

   ```bash
   uv venv --python 3.11
   uv pip install -r clickhouse/requirements.txt
   uv run python clickhouse/producer.py data/train.csv
   ```

   Продюсер отправляет около 786 тысяч строк. При повторном запуске данные загрузятся повторно: очистите ClickHouse (`TRUNCATE TABLE transactions_db.transactions`) и Kafka topic или используйте новую группу/топик.

   Результирующий файл можно пересчитать непосредственно из CSV (без запущенного ClickHouse):

   ```bash
   python clickhouse/export_largest_transaction.py data/train.csv
   ```

## dbt

ClickHouse должен быть запущен и таблица `transactions_db.transactions` загружена. dbt создаёт staging и marts в базе ClickHouse `transactions_db`.

```bash
uv venv .venv-dbt --python 3.12
uv pip install -r dbt/requirements.txt --python .venv-dbt
cp dbt/profiles.yml.example dbt/profiles.yml
cd dbt
dbt deps
dbt debug --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

По умолчанию профиль подключается к `localhost:8123` пользователем/паролем `dbt`. Переопределите значения переменными `CLICKHOUSE_HOST`, `CLICKHOUSE_PORT`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`. Если запускаете dbt в контейнере в той же сети Compose, укажите `CLICKHOUSE_HOST=clickhouse`.

Витрины: `mart_daily_state_metrics`, `mart_fraud_by_category`, `mart_fraud_by_state`, `mart_customer_risk_profile`, `mart_hourly_fraud_pattern`, `mart_merchant_analytics`. Подробности, определения терминов и типовой порядок отладки описаны в [`dbt/README.md`](dbt/README.md).

## Быстрые проверки

```bash
cd dbt
make deps
make check
pre-commit run --all-files
```

Unit tests выполняются командой `dbt test` вместе с data tests. Для DAG откройте dbt Docs после `dbt docs generate`.

## Остановка

```bash
docker compose down
```

Чтобы также удалить сохранённые таблицы ClickHouse: `docker compose down -v`.
