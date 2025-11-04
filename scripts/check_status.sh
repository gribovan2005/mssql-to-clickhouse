#!/bin/bash


echo "docker containers status"
docker-compose ps

echo "ms sql server status"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "SELECT @@VERSION" 2>/dev/null | head -3

echo "kafka broker status"
docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:29092 2>/dev/null | head -1

echo "schema registry status"
curl -s http://localhost:8081/subjects 2>/dev/null | python3 -m json.tool

echo "kafka connect status"
curl -s http://localhost:8083/connectors 2>/dev/null | python3 -m json.tool

echo "debezium connector status"
curl -s http://localhost:8083/connectors/mssql-audit-connector/status 2>/dev/null | python3 -m json.tool

echo "clickhouse status"
docker exec -i clickhouse clickhouse-client --query "SELECT version()" 2>/dev/null


echo "ms sql records"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; SELECT COUNT(*) FROM dbo.Audit;" -h -1 2>/dev/null | tail -1

echo "clickhouse records"
docker exec -i clickhouse clickhouse-client --query "SELECT count() FROM audit_db.audit" 2>/dev/null

echo "kafka topics"
docker exec kafka kafka-topics --bootstrap-server localhost:29092 --list 2>/dev/null | grep mssql

echo "consumer group lag"
docker exec kafka kafka-consumer-groups --bootstrap-server localhost:29092 --describe --group clickhouse_audit_group 2>/dev/null

echo "status check complete"

