#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

if [[ ! -f "${path}/wp-config.php" ]]; then
    wp core download --path=${path}    
fi
