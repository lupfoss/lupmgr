#!/usr/bin/env bash

sudo apt update
sudo apt install autossh

source config.sh

mkdir -p keys

echo "generating new keypair to login to Lightup, name=${LIGHTUP_CONNECT_KEYPAIR_NAME}"
if [[ ! -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} ]]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}
else
  echo "keypair already exists, skipping..."
fi

echo; echo "please share the following public key with Lightup (./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub):"; echo
cat ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub
