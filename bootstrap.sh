#!/bin/bash

set -e

TLA=${LU_TLA}
TOK=${LU_TOKEN}

set -e

BRANCH=onecmd

git clone https://github.com/lupfoss/lupmgr.git
cd lupmgr
git checkout ${BRANCH}

echo 'export LIGHTUP_CUSTOMER_TLA=${TLA}' > user_config.sh

source install_packages.sh
source setup_part_one.sh
source setup_part_two.sh

./connect.sh


