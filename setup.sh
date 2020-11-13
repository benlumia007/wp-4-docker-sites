#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

noroot mkdir -p ${path}

if [[ ! -f "${path}/wp-config.php" ]]; then
    noroot wp core download --path="${path}"
    noroot wp config create --dbhost=mysql --dbname=${domain} --dbuser=wordpress --dbpass=wordpress --path="${path}"
    noroot wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email --quiet --path="${path}"
    noroot wp plugin delete akismet --path="${path}"
    noroot wp plugin delete hello --path="${path}"
    noroot wp plugin install query-monitor --path="${path}" --activate
    noroot wp config shuffle-salts --path="${path}"
fi
