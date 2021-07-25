#!/usr/bin/env bash

# Use this script if the ssh tunnel will need to be established via an HTTP or
# HTTPS proxy.

# The script relies on the following environment variables:
# PROXY_SERVER
# PROXY_SERVER_PORT
#
# Optionally,
# PROXY_USER
# PROXY_USER_PASSWORD

# example usage of script:
# PROXY_SERVER=proxy.xxx.com PROXY_PORT=1233 PROXY_USER=xxxuser PROXY_PASSWORD=xxxpasswd ./proxy.sh
# PROXY_SERVER=proxy.xxx.com PROXY_PORT=1233 ./proxy.sh

source fixed_config.sh

if [[ "${PROXY_SERVER}" = "" || "${PROXY_PORT}" = "" ]]; then
    echo "Please setup PROXY_SERVER and PROXY_PORT before calling script"
    exit 1
fi

if [[ "${PROXY_USER}" != "" && "${PROXY_PASSWORD}" != "" ]]; then
    AUTH_COMMAND="--proxy-auth ${PROXY_USER}:${PROXY_PASSWORD}"
else
    AUTH_COMMAND=""
fi

server=${LIGHTUP_CONNECT_SERVER_NAME}
proxy_command="ProxyCommand ncat --proxy ${PROXY_SERVER}:${PROXY_PORT} %h %p ${AUTH_COMMAND}"

{
    echo ""
    echo "Host ${server}"
    echo "    ${proxy_command}"
}  >> ~/.ssh/config
