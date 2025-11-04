#!/bin/bash

echo "stopping and removing all services"
docker-compose down -v

echo "removing data directories"
rm -rf mssql-data clickhouse-data

