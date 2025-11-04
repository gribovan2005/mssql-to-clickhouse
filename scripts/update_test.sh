#!/bin/bash

echo "selecting a random record to update"
RECORD_ID=$(docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; SELECT TOP 1 AuditID FROM dbo.Audit ORDER BY NEWID();" -h -1 2>/dev/null | tail -1 | tr -d '[:space:]')

echo "updating record with auditid: $RECORD_ID"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; UPDATE dbo.Audit SET Status = 'UPDATED_TEST', Action = 'UPDATE_TEST' WHERE AuditID = $RECORD_ID;"

echo "waiting for replication"
sleep 5

echo "checking updated record in clickhouse"
docker exec -i clickhouse clickhouse-client --query "SELECT * FROM audit_db.audit WHERE AuditID = $RECORD_ID FORMAT Vertical"

echo "testing delete operation"
echo "deleting record with auditid: $RECORD_ID"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; DELETE FROM dbo.Audit WHERE AuditID = $RECORD_ID;"

echo "waiting for replication"
sleep 5

