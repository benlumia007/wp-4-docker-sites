#!/bin/bash

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "sites/${domain}/public_html"

    if ! grep -q "${host}" /etc/hosts; then
        echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
    fi

    cp "templates/wp-config.php" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_HOST/s/'[^']*'/'mysql'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_NAME/s/'[^']*'/'${domain}'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_USER/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
    sed -i -e "/DB_PASSWORD/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
    rm -rf "sites/${domain}/public_html/wp-config.php-e" 
fi