#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

this_dir=$(pwd)

AUTOSSH_DEBUG=1 \
AUTOSSH_LOGFILE="autossh.log" \
autossh -f -M 0 ${LIGHTUP_CONNECT_SERVER_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
	-o ExitOnForwardFailure=yes \
	-o UserKnownHostsFile=/dev/null \
	-o StrictHostKeyChecking=no \
	-R 9000:localhost:22 -vvv -i $this_dir/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}

err=$?

echo "autossh status code: $err"
ps aux | grep autossh
