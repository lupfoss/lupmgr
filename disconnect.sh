#!/usr/bin/env bash

set -x

source user_config.sh
source fixed_config.sh

echo "killing autossh by pid first..."
( [[ ! -f autossh.pid ]] && echo "no autossh.pid file found" ) || ( cat autossh.pid && sudo kill $(cat autossh.pid) )
echo

echo "killing autossh by regex..."
echo "following processes will be killed (if any):"
pgrep -f autossh.*${LIGHTUP_CONNECT_SERVER_NAME} || true
echo "----"
sudo pkill -f autossh.*${LIGHTUP_CONNECT_SERVER_NAME} || true
echo

echo "** output of ps aux | grep autossh:"
ps aux | grep autossh
echo

sudo rm -rf autossh.pid
sudo rm -rf autossh.log
