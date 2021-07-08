#!/usr/bin/env bash

# Setup the DB_HOST and DB_PORT variables before running this script

# DB Host: IP or DNS for the DB
# Eg:
# DB_HOST=192.168.86.22
# DB_HOST=analytics.us-east-1.redshift.amazonaws.com

DB_HOST=

# Port
# Eg:
# DB_PORT=5432
# DB_PORT=5439

DB_PORT=


# -------------------- Do not edit below this line ---------------------------

if [[ "${DB_HOST}" = "" ]]; then
    echo "Error - Please fill in DB_HOST - the name or IP of the database"
    exit 1
fi

if [[ "${DB_PORT}" = "" ]]; then
    echo "Please fill in DB_PORT - the port to connect to on the database"
    exit 1
fi

# shellcheck source=user_config.sh
source user_config.sh

# shellcheck source=fixed_config.sh
source fixed_config.sh

this_dir=$(pwd)

command="autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} \
	-p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
	-o ExitOnForwardFailure=yes \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o ServerAliveInterval=30 \
	-o ServerAliveCountMax=3 \
	-R 0.0.0.0:${DB_PORT}:${DB_HOST}:${DB_PORT} \
	-vvv -i ${this_dir}/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} &"

DEBUG=0

if [[ "${DEBUG}" = "1" ]]; then
    echo "${command}"
else
    eval "${command}"
fi
