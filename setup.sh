#!/bin/bash

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "config/templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "sites/${domain}/public_html"

    if ! grep -q "${domain}.test" /etc/hosts; then
        echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
    fi
fi
