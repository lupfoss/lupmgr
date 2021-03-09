#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

this_dir=$(pwd)

mkdir -p generated
./generate_command.sh > generated/connect_command.sh
chmod +x generated/connect_command.sh
./generated/connect_command.sh

err=$?

echo "autossh status code: $err"
ps aux | grep autossh
