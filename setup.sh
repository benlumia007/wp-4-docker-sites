#!/bin/bash

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "sites/${domain}/public_html"

    if ! grep -q "${domain}.test" /etc/hosts; then
        echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
    fi

    cp "templates/wp-config.php" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_HOST/s/'[^']*'/'mysql'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_NAME/s/'[^']*'/'${domain}'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_USER/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_PASSWORD/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
    rm -rf "sites/${domain}/public_html/wp-config.php-e" 

    wp core download --path=sites/${domain}/public_html

    docker exec -it docker-mysql mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${domain};"
    docker exec -it docker-mysql mysql -u root -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'wordpress';"
    docker exec -it docker-mysql mysql -u root -e "GRANT ALL PRIVILEGES ON ${domain}.* to 'wordpress'@'%' WITH GRANT OPTION;"
    docker exec -it docker-mysql mysql -u root -e "FLUSH PRIVILEGES;"

    docker exec -it docker-sandbox wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --allow-root --path=sites/${domain}/public_html

fi