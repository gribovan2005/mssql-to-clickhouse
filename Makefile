.PHONY: help setup start stop clean clean-data clean-all export-dashboards test monitor status insert update query logs grafana prometheus

setup:
	./scripts/setup.sh

start:
	docker-compose up -d

stop:
	./scripts/stop.sh

clean:
	./scripts/clean.sh

test:
	./scripts/test.sh

monitor:
	./scripts/monitor.sh

status:
	./scripts/check_status.sh

insert:
	./scripts/insert_test_data.sh

update:
	./scripts/update_test.sh

logs:
	docker-compose logs -f

logs-kafka:
	docker-compose logs -f kafka-connect

logs-mssql:
	docker-compose logs -f mssql

logs-ch:
	docker-compose logs -f clickhouse

connector-status:
	curl -s http://localhost:8083/connectors/mssql-audit-connector/status | python3 -m json.tool

connector-restart:
	curl -X DELETE http://localhost:8083/connectors/mssql-audit-connector
	sleep 5
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @config/debezium-connector-avro.json



