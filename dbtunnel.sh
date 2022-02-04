#!/usr/bin/env bash

# This script creates a tunnel to allow Lightup to connect to DBs that are
# internal to a customer network.
#
# Usage:
# DB_HOST=<host> DB_PORT=<port> ./dbtunnel.sh
#
# Examples for DB_HOST:
# DB_HOST=192.168.86.22
# DB_HOST=analytics.us-east-1.redshift.amazonaws.com
#
# Examples for DB_PORT:
# DB_PORT=5432
# DB_PORT=5439

if [[ "${DB_HOST}" = "" ||  "${DB_PORT}" = "" ]]; then
	echo "Error - DB_HOST or DB_PORT is not set"
	echo
	echo "Usage:"
	echo "DB_HOST=<host> DB_PORT=<port> ./dbtunnel.sh"
	echo
	exit 1
fi

# shellcheck source=user_config.sh
source user_config.sh

# shellcheck source=fixed_config.sh
source fixed_config.sh

command="autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} \
	-p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
	-o ExitOnForwardFailure=yes \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o ServerAliveInterval=30 \
	-o ServerAliveCountMax=3 \
	-R 0.0.0.0:${DB_PORT}:${DB_HOST}:${DB_PORT} \
	-vvv -i /opt/lightup//keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} &"

DEBUG=0

if [[ "${DEBUG}" = "1" ]]; then
	echo "${command}"
else
	eval "${command}"
fi
