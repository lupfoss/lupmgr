#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh
source utils.sh

this_dir=$(pwd)
private_ip=$(discover_private_ip)

reverse_port_list="-R ${LIGHTUP_CONNECT_MAPPED_PORT}:localhost:22 "
if [[ $INSTALL_DATAPLANE = "1" ]]
then
	reverse_port_list="${reverse_port_list} \
	-R 0.0.0.0:${LIGHTUP_DATAPLANE_ADMIN_PORT}:${private_ip}:${LIGHTUP_DATAPLANE_ADMIN_PORT} \
	-R 0.0.0.0:${LIGHTUP_DATAPLANE_APP_PORT}:${private_ip}:${LIGHTUP_DATAPLANE_APP_PORT} \
	-R 0.0.0.0:${LIGHTUP_DATAPLANE_K8S_PORT}:${private_ip}:${LIGHTUP_DATAPLANE_K8S_PORT}"
else
	reverse_port_list="${reverse_port_list} \
	-R 0.0.0.0:${DB_PORT}:${DB_HOST}:${DB_PORT}"
fi

echo  \
"AUTOSSH_DEBUG=1 \
AUTOSSH_LOGFILE=${this_dir}/autossh.log \
AUTOSSH_PIDFILE=${this_dir}/autossh.pid \
autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
	-o ExitOnForwardFailure=yes \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-o ServerAliveInterval=30 \
	-o ServerAliveCountMax=3 \
	${reverse_port_list} \
	-vvv -i $this_dir/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}"
