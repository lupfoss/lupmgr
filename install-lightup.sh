#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

set -e
set -x

echo "placing config onto the control plane..."
scp -o "StrictHostKeyChecking no" -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} *_config.sh ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/

echo "asking the control plane to install the dataplane asynchronously..."
ssh -o "StrictHostKeyChecking no" -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} 'bash -l -c ~/install-lightup-dataplane-async.sh'
