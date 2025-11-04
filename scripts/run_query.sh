#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "usage: ./run_query.sh [mssql|clickhouse] \"QUERY\""
    echo "example: ./run_query.sh clickhouse \"SELECT count() FROM audit_db.audit\""
    echo "example: ./run_query.sh mssql \"USE TestDB; SELECT COUNT(*) FROM dbo.Audit;\""
    exit 1
fi

DB_TYPE=$1
QUERY=$2

if [ "$DB_TYPE" = "mssql" ]; then
    docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C -Q "$QUERY"
elif [ "$DB_TYPE" = "clickhouse" ]; then
    docker exec -i clickhouse clickhouse-client --query "$QUERY"
else
    echo "error: unknown database type, use mssql or clickhouse"
    exit 1
fi

