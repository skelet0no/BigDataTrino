#!/bin/bash

set -e

CSV_DIR="/data"

sleep 10

mapfile -t files < <(find "$CSV_DIR" -maxdepth 1 -name "*.csv" | sort)

TOTAL=${#files[@]}
HALF=$((TOTAL / 2))

for ((i=0; i<HALF; i++)); do
    file="${files[$i]}"

    clickhouse-client \
    --query="INSERT INTO raw_clickhouse.mock_data FORMAT CSVWithNames" \
    < "$file"

done
