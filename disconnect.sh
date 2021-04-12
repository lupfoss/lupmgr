#!/usr/bin/env bash

set -x

source user_config.sh
source fixed_config.sh

echo "killing autossh by pid first..."
( [[ ! -f autossh.pid ]] && echo "not autossh.pid file found" ) || ( cat autossh.pid && kill $(cat autossh.pid) )
echo

echo "killing autossh by regex..."
echo "following processes will be killed (if any):"
pgrep -f autossh.*${LIGHTUP_CONNECT_SERVER_NAME}
echo "----"
sudo pkill -f autossh.*${LIGHTUP_CONNECT_SERVER_NAME} || true
echo

echo "** output of ps aux | grep autossh:"
ps aux | grep autossh
echo

rm -rf autossh.pid
