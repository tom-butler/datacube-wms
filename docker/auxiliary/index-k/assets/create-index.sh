#!/bin/bash

# Init system
datacube system init --no-init-users 2>&1

# Add product definitions to datacube
# URLS must be delimited with ':' and WITHOUT http(s)://
# Add product definitions to datacube
# URLS must be delimited with ':' and WITHOUT http(s)://
function add_products {
    mkdir -p firsttime/products

    IFS=: read -ra URLS <<< "$PRODUCT_URLS"

    for U in "${URLS[@]}"
    do
        wget -P firsttime/products $U -o $(echo $U | base64).yaml
    done

    for file in firsttime/products/*
    do
        datacube product add "$file"
    done
}

add_products

# Generate WMS specific config
PGPASSWORD=$DB_PASSWORD psql \
    -d $DB_DATABASE \
    -h $DB_HOSTNAME \
    -p $DB_PORT \
    -U $DB_USERNAME \
    -f /code/create_tables.sql 2>&1

# Run index
indexing/update_ranges_wrapper.sh
