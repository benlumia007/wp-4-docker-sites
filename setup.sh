#!/bin/bash

config="config/docker-custom.yml"

get_sites() {
    local value=`cat ${config} | shyaml keys sites 2> /dev/null`
    echo ${value:-$@}
}

for domain in `get_sites`; do
    provision=`cat ${config} | shyaml get-value sites.${domain}.provision`

    if [[ "True" == ${provision} ]]; then
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
            if grep -q "{{HOST}}" "config/nginx/${domain}.conf"; then
                sed -i -e "s/{{HOST}}/${host}/g" "config/nginx/${domain}.conf"
                rm -rf "config/nginx/${domain}.conf-e"
            fi

            if ! grep -q "${host}" /etc/hosts; then
            echo "127.0.0.1     ${domain}.test" | sudo tee -a /etc/hosts
            fi
        done

        cp "templates/wp-config.php" "sites/${domain}/public_html/wp-config.php"
        sed -i -e "/DB_HOST/s/'[^']*'/'mysql'/2" "sites/${domain}/public_html/wp-config.php"
        sed -i -e "/DB_NAME/s/'[^']*'/'${domain}'/2" "sites/${domain}/public_html/wp-config.php"
        sed -i -e "/DB_USER/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
        sed -i -e "/DB_PASSWORD/s/'[^']*'/'wordpress'/2" "sites/${domain}/public_html/wp-config.php"
        rm -rf "sites/${domain}/public_html/wp-config.php-e"
    fi
done