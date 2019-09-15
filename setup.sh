#!/bin/bash

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi

    mkdir -p "sites/${domain}/public_html"
fi

get_hosts() {
    local value=`cat ${config} | shyaml get-value sites.${domain}.host`
    echo ${value:$@}
}

for host in `get_hosts`; do 
    echo ${host}
    exit 1
    if grep -q "{{HOST}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{HOST}}/${host}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi

    if ! grep -q "${host}" /etc/hosts; then
    echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
    fi
done