#!/usr/bin/env bash

DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
APP_NAME=`get_config_value 'app_name' "${VVV_SITE_NAME}"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}
DB_USERNAME=`get_config_value 'db_username' "root"`
DB_PASSWORD=`get_config_value 'db_password' "root"`
DB_PREFIX=""

# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/nginx-error.log
touch ${VVV_PATH_TO_SITE}/log/nginx-access.log

# Install and configure the latest stable version of Slim REST
## Create project
composer create-project awurth/slim-rest-base ${VVV_PATH_TO_SITE}/public_html
## Create database
cp "${VVV_PATH_TO_SITE}/public_html/.env.dist" "${VVV_PATH_TO_SITE}/public_html/.env"
sed -i "s#APP_DATABASE_DATABASE=slim_rest#APP_DATABASE_DATABASE=${DB_NAME}#" "${VVV_PATH_TO_SITE}/public_html/.env"
sed -i "s#APP_DATABASE_USERNAME=root#APP_DATABASE_USERNAME=${DB_USERNAME}#" "${VVV_PATH_TO_SITE}/public_html/.env"
sed -i "s#APP_DATABASE_PASSWORD=#APP_DATABASE_PASSWORD=${DB_PASSWORD}#" "${VVV_PATH_TO_SITE}/public_html/.env"
sed -i "s#APP_DATABASE_PREFIX=#APP_DATABASE_PREFIX=${DB_PREFIX}#" "${VVV_PATH_TO_SITE}/public_html/.env"
php bin/console db
## Set URL (dev)
sed -i "s#http://localhost/slim-rest-base#${DOMAIN}#" "${VVV_PATH_TO_SITE}/public_html/config/services.dev.php"

# Nginx configuration
cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"

if [ -n "$(type -t is_utility_installed)" ] && [ "$(type -t is_utility_installed)" = function ] && `is_utility_installed core tls-ca`; then
    sed -i "s#{{TLS_CERT}}#ssl_certificate /vagrant/certificates/${VVV_SITE_NAME}/dev.crt;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}#ssl_certificate_key /vagrant/certificates/${VVV_SITE_NAME}/dev.key;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
    sed -i "s#{{TLS_CERT}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi
