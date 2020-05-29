#!/bin/bash

get_preprocessor() {
    local value=`cat ${config} | shyaml get-value preprocessor 2> /dev/null`
    echo ${value:-$@}
}

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
