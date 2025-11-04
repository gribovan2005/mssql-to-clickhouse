#!/bin/bash

set -e

echo "testing ms sql server"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; SELECT COUNT(*) AS TotalRecords FROM dbo.Audit;"

echo "testing kafka topics"
docker exec kafka kafka-topics --bootstrap-server localhost:29092 --list

echo "testing debezium connector status"
curl -s http://localhost:8083/connectors/mssql-audit-connector/status | python3 -m json.tool

echo "testing clickhouse"
docker exec -i clickhouse clickhouse-client --query "SELECT count() FROM audit_db.audit FORMAT Vertical"

echo "sample data from clickhouse"
docker exec -i clickhouse clickhouse-client --query "SELECT * FROM audit_db.audit LIMIT 5 FORMAT Vertical"

echo "testing real-time replication"
echo "inserting new record into ms sql"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; INSERT INTO dbo.Audit (UserID, Username, Email, Action, EntityType, EntityID, Status) VALUES (999, 'test_user', 'test@example.com', 'TEST', 'TestEntity', 12345, 'SUCCESS');"

echo "waiting for replication"
sleep 5

echo "checking new record in clickhouse"
docker exec -i clickhouse clickhouse-client --query "SELECT * FROM audit_db.audit WHERE UserID = 999 FORMAT Vertical"

