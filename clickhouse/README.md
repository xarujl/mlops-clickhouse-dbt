# ClickHouse

## Основные файлы

- `docker-compose.yml` поднимает три сервиса: Zookeeper хранит состояние кластера Kafka, Kafka принимает сообщения, ClickHouse читает их и хранит данные.
- `clickhouse/producer.py` — отдельный CSV-продюсер. Он превращает каждую строку CSV в JSON-сообщение; ClickHouse читает формат `JSONEachRow`.
- `clickhouse/config/kafka.xml` сообщает ClickHouse адрес Kafka внутри Docker-сети.
- `clickhouse/init/01_schema.sql` создает очередь-таблицу, целевую таблицу и materialized view.
- `clickhouse/queries/largest_transaction_category_by_state.sql` выбирает крупнейшую транзакцию внутри каждого штата.
- `clickhouse/export_largest_transaction.py` создает такой же отчет прямо из исходного CSV, если база пока не запущена.

## Запуск и диагностика

Из корневой папки выполните шаги из главного README. Проверить сервисы можно командами:

```bash
docker compose ps
docker compose logs kafka
docker compose logs clickhouse
docker compose exec clickhouse clickhouse-client --query "SHOW TABLES FROM transactions_db"
docker compose exec clickhouse clickhouse-client --query "SELECT count() FROM transactions_db.transactions"
```

## Запрос категория самой крупной транзакции по штату

Оконная функция `row_number()` упорядочивает транзакции внутри каждого штата по убыванию суммы. Дополнительные поля дают предсказуемый результат при равной сумме. SQL-файл можно запускать через `clickhouse-client`; чтобы получить CSV, перенаправьте вывод в файл, как показано в корневом README.

Для воспроизводимого результата из оригинального файла используйте Python-экспортер. Он требует только стандартную библиотеку Python, читает файл потоково и держит в памяти только лучший результат для каждого штата.

## Остановка

`docker compose down` останавливает сервисы, но сохраняет ClickHouse volume. `docker compose down -v` удаляет и сохраненную базу.
