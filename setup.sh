#!/bin/bash

config=".global/docker-custom.yml"
dir="${dir}/public_html"

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
    mkdir -p "${dir}"

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
