#!/bin/bash

echo "populating audit table with 1000 records"

for i in {1..1000}; do
    UserID=$((RANDOM % 100 + 1))
    Username="user_$((RANDOM % 1000))"
    Email="${Username}@example.com"
    Actions=("CREATE" "UPDATE" "DELETE" "VIEW" "EXPORT" "IMPORT" "LOGIN" "LOGOUT")
    Action=${Actions[$((RANDOM % 8))]}
    EntityTypes=("User" "Order" "Product" "Invoice" "Payment" "Document" "Report")
    EntityType=${EntityTypes[$((RANDOM % 7))]}
    EntityID=$((RANDOM % 10000 + 1))
    IPAddress="192.168.$((RANDOM % 255)).$((RANDOM % 255))"
    SessionID=$(uuidgen | tr '[:upper:]' '[:lower:]')
    Statuses=("SUCCESS" "FAILED" "PENDING" "WARNING")
    Status=${Statuses[$((RANDOM % 4))]}
    
    docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; INSERT INTO dbo.Audit (UserID, Username, Email, Action, EntityType, EntityID, IPAddress, SessionID, Status) VALUES ($UserID, '$Username', '$Email', '$Action', '$EntityType', $EntityID, '$IPAddress', '$SessionID', '$Status');" > /dev/null 2>&1
    
    if [ $((i % 100)) -eq 0 ]; then
        echo "Inserted $i records"
    fi
done

echo "checking record count"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "USE TestDB; SELECT COUNT(*) AS TotalRecords FROM dbo.Audit;"

