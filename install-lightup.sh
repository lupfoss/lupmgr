#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

set -e
set -x

LIGHTUP_KOTS_APP_NAME=lightup
LIGHTUP_KOTS_SHARED_PASSWORD=changeImmediately123
LIGHTUP_K8S_NAMESPACE=default
LIGHTUP_DISTRIBUTION=lightup-beta
LIGHTUP_LICENSE_FILENAME=${LIGHTUP_TLA}.yaml
LIGHTUP_LICENSE_FILE_LOCAL_PATH=./license/${LIGHTUP_LICENSE_FILENAME}

echo "pulling license file before installing Lightup..."
mkdir -p ./license
scp -o "StrictHostKeyChecking no" -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_LICENSE_FILENAME}" ${LIGHTUP_LICENSE_FILE_LOCAL_PATH}


echo "installing the Lightup deployment controller..."
curl -sSL https://k8s.kurl.sh/${LIGHTUP_DISTRIBUTION} | sudo bash


echo "installing the Lightup dataplane as a kots application..."
kubectl kots install ${LIGHTUP_KOTS_APP_NAME} \
  --license-file ${LIGHTUP_LICENSE_FILE_LOCAL_PATH} \
  --shared-password ${LIGHTUP_KOTS_SHARED_PASSWORD} \
  --namespace ${LIGHTUP_K8S_NAMESPACE}
