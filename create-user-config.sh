#!/bin/bash

echo "export LIGHTUP_TLA=${LIGHTUP_TLA}" > user_config.sh
echo "export INSTALL_DATAPLANE=${INSTALL_DATAPLANE}" >> user_config.sh
echo "export LIGHTUP_CONNECT_KEYPAIR_NAME=${LIGHTUP_CONNECT_KEYPAIR_NAME}" >> user_config.sh
echo "export LIGHTUP_CONNECT_MAPPED_PORT=${LIGHTUP_CONNECT_MAPPED_PORT}" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_USERNAME=$(whoami)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_LUPMGR_DIR=$(pwd)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_HOMEDIR=${HOME}" >> user_config.sh
