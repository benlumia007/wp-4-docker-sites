#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

if [[ ! -f "${path}/wp-config.php" ]]; then
    mkdir -p ${path}
    wp core download --path=${path}    
fi
