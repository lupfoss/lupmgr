#!/usr/bin/env bash

set -x

source user_config.sh
source fixed_config.sh

echo "killing autossh by pid first..."
( [[ ! -f autossh-dataplane.pid ]] && echo "no autossh-dataplane.pid file found" ) || ( cat autossh-dataplane.pid && sudo kill $(cat autossh-dataplane.pid) )
( [[ ! -f autossh-connect.pid ]] && echo "no autossh-connect.pid file found" ) || ( cat autossh-connect.pid && sudo kill $(cat autossh-connect.pid) )
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

sudo rm -rf autossh-dataplane.pid
sudo rm -rf autossh-dataplane.log
sudo rm -rf autossh-connect.pid
sudo rm -rf autossh-connect.log
