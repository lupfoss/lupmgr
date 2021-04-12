#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

set +e
set -x

this_dir=$(pwd)

if [[ -f autossh.pid ]]; then
	echo "ERROR: autossh.pid already exists, not starting another autossh, run ./disconnect.sh first and then try again"
	exit 1
fi

mkdir -p generated
./generate_command.sh > generated/connect_command.sh
chmod +x generated/connect_command.sh
source generated/connect_command.sh

err=$?

echo "** autossh status code: $err"
echo

echo "** output of ps aux | grep autossh:"
ps aux | grep autossh
echo

if [[ ! $err -eq "0" ]]; then
	echo "** output of tail /var/log/syslog | grep autossh:"
	tail /var/log/syslog | grep autossh
	echo

	echo "** output of cat autossh.log:"
	cat autossh.log
	echo
fi
