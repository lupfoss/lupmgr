#!/usr/bin/env bash

source config.sh

echo "adding Lightup's public key to authorized keys..."
scp -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" ./keys/
mkdir -p ~/.ssh && cat "./keys/${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" >> ~/.ssh/authorized_keys


