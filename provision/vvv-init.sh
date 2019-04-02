#!/usr/bin/env bash

DOMAIN=`get_primary_host "${VVV_SITE_NAME}".test`
APP_NAME=`get_config_value 'app_name' "${VVV_SITE_NAME}"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}
DB_USERNAME="root"
DB_PASSWORD="root"
DB_PREFIX=""

# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/nginx-error.log
touch ${VVV_PATH_TO_SITE}/log/nginx-access.log

# Install and configure the latest stable version of Slim REST
## Create project
composer create-project awurth/slim-rest-base ${APP_NAME}
## Create database
cp "${VVV_PATH_TO_SITE}/.env.dist" "${VVV_PATH_TO_SITE}/.env"
sed -i "s#APP_DATABASE_DATABASE=slim_rest#APP_DATABASE_DATABASE=${DB_NAME}#" "${VVV_PATH_TO_SITE}/.env"
sed -i "s#APP_DATABASE_USERNAME=root#APP_DATABASE_USERNAME=${DB_USERNAME}#" "${VVV_PATH_TO_SITE}/.env"
sed -i "s#APP_DATABASE_PASSWORD=#APP_DATABASE_PASSWORD=${DB_PASSWORD}#" "${VVV_PATH_TO_SITE}/.env"
sed -i "s#APP_DATABASE_PREFIX=#APP_DATABASE_PREFIX=${DB_PREFIX}#" "${VVV_PATH_TO_SITE}/.env"
php bin/console db
## Set URL (dev)
sed -i "s#http://localhost/slim-rest-base#${DOMAIN}#" "${VVV_PATH_TO_SITE}/config/services.dev.php"