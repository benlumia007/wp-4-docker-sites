#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

mkdir -p ${path}

if [[ ! -f "${path}/wp-config.php" ]]; then
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${domain};"
    mysql -u root -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'wordpress';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${domain}.* to 'wordpress'@'%' WITH GRANT OPTION;"
    mysql mysql -u root -e "FLUSH PRIVILEGES;"
    
    wp core download --path="${path}"
    wp config create --dbhost=localhost --dbname=${domain} --dbuser=wordpress --dbpass=wordpress --path="${path}"
    wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email --quiet --path="${path}"
    wp plugin delete akismet --path="${path}"
    wp plugin delete hello --path="${path}"
    wp config shuffle-salts --path="${path}"
fi
