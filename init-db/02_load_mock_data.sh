#!/bin/bash

set -e

DB_NAME="${POSTGRES_DB:-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"

CSV_DIR="/docker-entrypoint-initdb.d/data"

until pg_isready -U "$DB_USER"; do
    sleep 2
done

mapfile -t files < <(find "$CSV_DIR" -maxdepth 1 -name "*.csv" | sort)

TOTAL=${#files[@]}
HALF=$((TOTAL / 2))

for ((i=HALF; i<TOTAL; i++)); do
    file="${files[$i]}"

    psql -v ON_ERROR_STOP=1 \
         --username "$DB_USER" \
         --dbname "$DB_NAME" <<EOSQL
COPY mock_data
FROM '$file'
DELIMITER ','
CSV HEADER;
EOSQL

done
