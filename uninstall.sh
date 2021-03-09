#!/usr/bin/env bash

sudo cp rc.local.clean /etc/rc.local
sudo chmod +x /etc/rc.local
./disconnect.sh
