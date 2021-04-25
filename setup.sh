#!/bin/bash

compose=$PWD/.global/docker-compose.yml
path=${dir}/public_html

noroot mkdir -p ${path}


if [[ "none" == ${type} ]]; then
    if [[ ! -f "${path}/index.php" ]]; then
        noroot touch "${path}/index.php"
    fi
elif [[ "ClassicPress" == ${type} ]]; then
    if [[ ! -f "${path}/wp-config.php" ]]; then
        noroot wp core download --path="${path}" https://www.classicpress.net/latest.zip
        noroot wp config create --dbhost=mysql --dbname=${domain} --dbuser=classicpress --dbpass=classicpress --path="${path}"
        noroot wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email --quiet --path="${path}"
        noroot wp plugin install query-monitor --path="${path}" --activate
        noroot wp config shuffle-salts --path="${path}"
    fi
else
    if [[ ! -f "${path}/wp-config.php" ]]; then
        noroot wp core download --path="${path}"
        noroot wp config create --dbhost=mysql --dbname=${domain} --dbuser=wordpress --dbpass=wordpress --path="${path}"
        noroot wp core install  --url="https://${domain}.test" --title="${domain}.test" --admin_user=admin --admin_password=password --admin_email="admin@${domain}.test" --skip-email --quiet --path="${path}"

        if [[ "${plugins}" != "none" ]]; then
          for plugin in ${plugins//- /$'\n'}; do
            if [[ "${plugin}" != "plugins" ]]; then
              noroot wp plugin install ${plugin} --activate --quiet
            fi
          done
        fi

        if [[ "${themes}" != "none" ]]; then
          for theme in ${themes//- /$'\n'}; do
            if [[ "${theme}" != "themes" ]]; then
              noroot wp theme install ${theme} --activate --quiet
            fi
          done
        fi

        if [[ "${constants}" != "none" ]]; then
          for const in ${constants//- /$'\n'}; do
            if [[ "${const}" != "constants" ]]; then
              noroot wp config set --type=constant ${const} --raw true --quiet
            fi
          done
        fi
    fi
fi

