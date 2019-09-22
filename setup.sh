#!/bin/bash

dir="${dir}"

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "config/templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "${dir}"

    if ! grep -q "${domain}.test" /etc/hosts; then
        echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
    fi

    wp core download --path=${dir}

    cp "config/templates/wp-config.php" "${dir}/wp-config.php"
    sed -i -e "/DB_HOST/s/'[^']*'/'mysql'/2" "${dir}/wp-config.php"
    sed -i -e "/DB_NAME/s/'[^']*'/'${domain}'/2" "${dir}/wp-config.php"
    sed -i -e "/DB_USER/s/'[^']*'/'wordpress'/2" "${dir}/wp-config.php"
    sed -i -e "/DB_PASSWORD/s/'[^']*'/'wordpress'/2" "${dir}/wp-config.php"
    rm -rf "${dir}/wp-config.php-e"

    docker exec -it docker-mysql mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${domain};"
    docker exec -it docker-mysql mysql -u root -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'wordpress';"
    docker exec -it docker-mysql mysql -u root -e "GRANT ALL PRIVILEGES ON ${domain}.* to 'wordpress'@'%' WITH GRANT OPTION;"
    docker exec -it docker-mysql mysql -u root -e "FLUSH PRIVILEGES;"

    docker exec -it docker-phpfpm wp core install  --url="https://${domain}.test" --title="${site_title}" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --path=/var/www/html/${domain}/public_html --allow-root
    docker exec -it docker-phpfpm wp config shuffle-salts --path=/var/www/html/${domain}/public_html --allow-root
fi
