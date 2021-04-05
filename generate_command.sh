#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

this_dir=$(pwd)

# TODO: 
# need to add tunnels for 8443 and 8800 to access Lightup Application UI, Lightup Enterprise UI.
# -R 0.0.0.0:8800:<private_ip>:8800
# -R 0.0.0.0:8443:<private_ip>:8443




echo  \
"AUTOSSH_DEBUG=1 \
AUTOSSH_LOGFILE=${this_dir}/autossh.log \
autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
	-o ExitOnForwardFailure=yes \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o ServerAliveInterval=30 \
	-o ServerAliveCountMax=3 \
	-R ${LIGHTUP_CONNECT_MAPPED_PORT}:localhost:22 \
	-i $this_dir/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}"
