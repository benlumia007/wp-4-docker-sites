#!/bin/bash

path="${dir}/public_html"

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "config/templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "${path}"

    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
        if ! grep -q "${domain}.test" /mnt/c/Windows/System32/drivers/etc/hosts; then
            echo "127.0.0.1   ${domain}.test" | sudo tee -a /mnt/c/Windows/System32/drivers/etc/hosts
        fi
    else
        if ! grep -q "dashboard.test" /etc/hosts; then
            echo "127.0.0.1   ${domain}.test" | sudo tee -a /etc/hosts
        fi
    fi
fi
