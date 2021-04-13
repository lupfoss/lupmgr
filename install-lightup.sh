#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

set -e
set -x

APP_NAME=lightup
LICENSE_FILE=./license/${LIGHTUP_CUSTOMER_TLA}.yaml
SHARED_PASSWORD=changeImmediately123
NAMESPACE=default

kubectl kots install ${APP_NAME} \
  --license-file ${LICENSE_FILE} \
  --shared-password ${SHARED_PASSWORD} \
  --namespace ${NAMESPACE}
