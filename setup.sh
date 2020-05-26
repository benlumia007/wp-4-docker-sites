#!/bin/bash

config=".global/docker-custom.yml"
site="${dir}/public_html"

get_sites() {
    local value=`cat ${config} | shyaml keys sites 2> /dev/null`
    echo ${value:-$@}
}

get_preprocessor() {
    local value=`cat ${config} | shyaml get-value preprocessor 2> /dev/null`
    echo ${value:-$@}
}

if [[ ! -f "config/nginx/${domain}.conf" ]]; then
    mkdir -p "config/nginx"
    cp "config/templates/nginx.conf" "config/nginx/${domain}.conf"

    if grep -q "{{DOMAIN}}" "config/nginx/${domain}.conf"; then
        sed -i -e "s/{{DOMAIN}}/${domain}/g" "config/nginx/${domain}.conf"
        rm -rf "config/nginx/${domain}.conf-e"
    fi
    mkdir -p "${site}"

    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
        if ! grep -q "${domain}.test" /mnt/c/Windows/System32/drivers/etc/hosts; then
            echo "127.0.0.1   ${domain}.test" | sudo tee -a /mnt/c/Windows/System32/drivers/etc/hosts
        fi
    else
        if ! grep -q "${domain}.test" /etc/hosts; then
            echo "127.0.0.1   ${domain}.test" | sudo tee -a /etc/hosts
        fi
    fi
fi

get_site_provision() {
    local value=`cat ${config} | shyaml get-value sites.${domain}.provision 2> /dev/null`
    echo ${value:-$@}
}

provision=`get_site_provision`

if [[ "True" == ${provision} ]]; then
    dir="sites/${domain}/public_html"
    path="/srv/www/${domain}/public_html"

    if [[ ! -f "${dir}/wp-config.php" ]]; then
        docker exec -it docker-mysql mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${domain};"
        docker exec -it docker-mysql mysql -u root -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' IDENTIFIED WITH 'mysql_native_password' BY 'wordpress';"
        docker exec -it docker-mysql mysql -u root -e "GRANT ALL PRIVILEGES ON ${domain}.* to 'wordpress'@'%' WITH GRANT OPTION;"
        docker exec -it docker-mysql mysql -u root -e "FLUSH PRIVILEGES;"

        docker exec -it docker-nginx wp core download --path="${path}" --allow-root
        docker exec -it docker-nginx wp config create --dbhost=mysql --dbname=${domain} --dbuser=wordpress --dbpass=wordpress --path="${path}" --allow-root
        docker exec -it docker-nginx wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --path=${path} --allow-root
        docker exec -it docker-nginx wp plugin delete akismet --path=${path} --allow-root
        docker exec -it docker-nginx wp plugin delete hello --path=${path} --allow-root
        docker exec -it docker-nginx wp config shuffle-salts --path=${path} --allow-root

        docker exec -it docker-nginx chown -R 1000:1000 ${path}
    fi
fi
preprocessors=`get_preprocessor`

for php in ${preprocessors//- /$'\n'}; do

    if [[ ${php} == "7.2" ]]; then
        if grep -q "7.3" config/nginx/${domain}.conf; then
            sed -i -e "s/7.3/${php}/g" "config/nginx/${domain}.conf"
        elif grep -q "7.4" config/nginx/${domain}.conf; then
            sed -i -e "s/7.4/${php}/g" "config/nginx/${domain}.conf"
        else
            sed -i -e "s/{{PHPVERSION}}/${php}/g" "config/nginx/${domain}.conf"
        fi
    elif [[ ${php} == "7.3" ]]; then
        if grep -q "7.2" config/nginx/${domain}.conf; then
            sed -i -e "s/7.2/${php}/g" "config/nginx/${domain}.conf"
        elif grep -q "7.4" config/nginx/${domain}.conf; then
            sed -i -e "s/7.4/${php}/g" "config/nginx/${domain}.conf"
        else
            sed -i -e "s/{{PHPVERSION}}/${php}/g" "config/nginx/${domain}.conf"
        fi
    elif [[ ${php} == "7.4" ]]; then
        if grep -q "7.2" config/nginx/${domain}.conf; then
            sed -i -e "s/7.2/${php}/g" "config/nginx/${domain}.conf"
        elif grep -q "7.3" config/nginx/${domain}.conf; then
            sed -i -e "s/7.3/${php}/g" "config/nginx/${domain}.conf"
        else
            sed -i -e "s/{{PHPVERSION}}/${php}/g" "config/nginx/${domain}.conf"
        fi
    fi

done
