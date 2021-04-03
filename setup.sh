#!/bin/bash

git clone https://github.com/lupfoss/lupmgr.git
cd lupmgr
echo 'export LIGHTUP_CUSTOMER_TLA=${LIGHTUP_CUSTOMER_TLA}' > user_config.sh

RHEL7
./rhel7_setup_part_one.sh

RHEL8
./rhel8_setup_part_one.sh

Ubuntu 20.04
./setup_part_one.sh

# send public key to Lightup for activation


./setup_part_two.sh


./connect.sh


