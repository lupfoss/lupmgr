#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

sudo pkill -f autossh.*${LIGHTUP_CONNECT_SERVER_NAME} || true
