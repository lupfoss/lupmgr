#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh
source utils.sh

set +e
set -x

this_dir=$(pwd)

if [[ -f autossh-connect.pid ]]; then
	echo "ERROR: autossh-connect.pid already exists, not starting another autossh, run ./disconnect.sh first and then try again"
	exit 1
fi

if [[ -f autossh-dataplane.pid ]]; then
    echo "ERROR: autossh-dataplane.pid already exists, not starting another autossh, run ./disconnect.sh first and then try again"
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

	echo "** output of cat autossh-dataplane.log:"
	cat autossh-dataplane.log
	echo

    echo "** output of cat autossh-connect.log:"
    cat autossh-connect.log
    echo
fi
