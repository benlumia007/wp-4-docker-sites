#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

mkdir -p ${path}

if [[ ! -f "${path}/wp-config.php" ]]; then
    wp core download --path="${path}"
    wp config create --dbhost=mysql --dbname=${domain} --dbuser=wordpress --dbpass=wordpress --path="${path}"
    wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email --quiet --path="${path}"
    wp plugin delete akismet --path="${path}"
    wp plugin delete hello --path="${path}"
    wp config shuffle-salts --path="${path}"
fi
