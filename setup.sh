#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

if [[ ! -f "${path}/wp-config.php" ]]; then
    docker-compose -f ${compose} exec mysql mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${domain};"` );
    docker-compose -f ${compose} exec mysql mysql -u root -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'wordpress';"` );
    docker-compose -f ${compose} exec mysql mysql -u root -e "GRANT ALL PRIVILEGES ON ${domain}.* to 'nginx'@'%' WITH GRANT OPTION;"` );
    docker-compose -f ${compose} exec mysql mysql -u root -e "FLUSH PRIVILEGES;"` );
    
    
fi
