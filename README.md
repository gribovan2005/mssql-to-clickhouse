# MS SQL -> ClickHouse CDC Pipeline

Тестовый проект для репликации данных из MS SQL Server в ClickHouse через Kafka с использованием Debezium CDC

## Реализация

- **CDC** - отслеживание изменений в MS SQL через Debezium
- **Avro + Schema Registry** - сериализация данных с контролем схем
- **Kafka Connect** - интеграция Debezium с Kafka
- **ClickHouse Kafka Engine** - потребление Avro сообщений из Kafka
- **Materialized View** - автоматическая трансформация данных в ClickHouse

Данные передаются в формате Avro через Confluent Schema Registry

## Стек

- **MS SQL Server** - источник данных с таблицей Audit (1000 записей)
- **Kafka + Zookeeper** - транспорт данных
- **Debezium** - CDC коннектор
- **Schema Registry** - управление Avro схемами
- **ClickHouse** - целевое хранилище
- **Grafana + Prometheus** - мониторинг

## Быстрый старт

```bash
make setup    # запуск всей инфраструктуры
make test     # тест репликации
make clean    # остановка и очистка
```

## Мониторинг

- Kafka UI: http://localhost:8080
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090

## Структура

```
config/          # конфигурации Debezium, Prometheus, Grafana
sql/             # SQL скрипты для MS SQL и ClickHouse
scripts/         # bash скрипты для автоматизации
```

# mssql-to-clickhouse
