#!/bin/bash

set -e

echo "starting all services"
docker-compose up -d

echo "waiting for services to be ready"
sleep 30

echo "waiting for ms sql server to be ready"
until docker exec mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -Q "SELECT 1" -C &> /dev/null
do
  echo "waiting for ms sql server"
  sleep 5
done

echo "initializing ms sql database and table"
docker exec -i mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Pass@word123' -C < sql/init-mssql.sql

echo "waiting for kafka connect to be ready"
until curl -s http://localhost:8083/ &> /dev/null
do
  echo "waiting for kafka connect"
  sleep 5
done

echo "waiting for schema registry to be ready"
until curl -s http://localhost:8081/ &> /dev/null
do
  echo "waiting for schema registry"
  sleep 5
done

sleep 10

echo "creating debezium connector"
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  http://localhost:8083/connectors/ -d @config/debezium-connector-avro.json

  echo "waiting for connector to be ready"
sleep 10

echo "populating ms sql with test data"
./scripts/populate_direct.sh

echo "waiting for data to be synced"
sleep 15

echo "setting up clickhouse tables"
docker exec -i clickhouse clickhouse-client --multiquery < sql/init-clickhouse-avro.sql

