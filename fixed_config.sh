#!/usr/bin/env bash

if [[ "${LIGHTUP_TLA}" = "" ]]; then
    echo "Error - LIGHTUP_TLA is not set"
    exit 1
fi

# if tunneling through a http/https proxy, update this to port 80/443 as necessary
export LIGHTUP_CONNECT_SERVER_PORT=22

# Do not edit the variables below:
export LIGHTUP_ACCEPT_KEYPAIR_NAME="lightup-to-${LIGHTUP_TLA}"
export LIGHTUP_CONNECT_SERVER_NAME="connect.${LIGHTUP_TLA}.lightup.ai"
export LIGHTUP_CONNECT_USER_NAME="ubuntu"
export LIGHTUP_DATAPLANE_ADMIN_PORT=8800
export LIGHTUP_DATAPLANE_APP_PORT=8443
export LIGHTUP_CONNECT_APP_PORT=443
export LIGHTUP_DATAPLANE_K8S_PORT=8080
