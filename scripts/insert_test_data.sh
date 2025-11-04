#!/bin/bash

echo "inserting test records into ms sql"

for i in {1..10}; do
    docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; INSERT INTO dbo.Audit (UserID, Username, Email, Action, EntityType, EntityID, Status) VALUES ($((RANDOM % 1000)), 'user_$i', 'user$i@test.com', 'INSERT', 'TestData', $((RANDOM % 10000)), 'SUCCESS');"
    echo "Inserted record $i"
    sleep 1
done

echo "waiting for replication"
sleep 5

echo "last 10 records in clickhouse"
docker exec -i clickhouse clickhouse-client --query "SELECT AuditID, Username, Email, Action, Timestamp FROM audit_db.audit ORDER BY Timestamp DESC LIMIT 10 FORMAT Pretty"

