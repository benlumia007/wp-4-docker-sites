#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

if [[ ! -f "${path}/wp-config.php" ]]; then
  echo "let's download the core ifles"
fi
