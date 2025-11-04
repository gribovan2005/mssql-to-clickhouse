#!/bin/bash

while true; do
    clear
    echo "ms sql to clickhouse monitor"
    
    echo "ms sql records"
    docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; SELECT COUNT(*) AS Records FROM dbo.Audit;" -h -1 2>/dev/null | tail -1

    echo "clickhouse records"
    docker exec -i clickhouse clickhouse-client --query "SELECT count() FROM audit_db.audit" 2>/dev/null
    
    echo "connector status"
    STATUS=$(curl -s http://localhost:8083/connectors/mssql-audit-connector/status 2>/dev/null | python3 -c "import sys, json; data=json.load(sys.stdin); print(f\"State: {data['connector']['state']}, Tasks: {data['tasks'][0]['state'] if data['tasks'] else 'N/A'}\")" 2>/dev/null)
    echo "$STATUS"
    
    echo "kafka topics"
    docker exec kafka kafka-topics --bootstrap-server localhost:29092 --list 2>/dev/null | grep -c mssql
    
    echo "last 3 records in clickhouse"
    docker exec -i clickhouse clickhouse-client --query "SELECT AuditID, Username, Action, Status, Timestamp FROM audit_db.audit ORDER BY Timestamp DESC LIMIT 3 FORMAT Pretty" 2>/dev/null
    
    echo "press ctrl+c to exit"
    sleep 5
done

