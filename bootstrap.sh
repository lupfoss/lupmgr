#!/bin/bash

set -eux -o pipefail

TLA=${LU_TLA}
TOK=${LU_TOKEN}

# determine distro

if [[ -f /etc/lsb-release && $(grep -Eo 'DISTRIB_ID=Ubuntu' /etc/lsb-release) ]]; then
    DISTRO="Ubuntu"
fi

if [[ -f /etc/redhat-release && $(grep -Eo 'release 7\.' /etc/redhat-release) ]]; then
    DISTRO="RHEL7"
fi

if [[ -f /etc/redhat-release && $(grep -Eo 'release 8\.' /etc/redhat-release) ]]; then
    DISTRO="RHEL8"
fi

if [[ x$DISTRO = x ]]; then
    echo "error: distribution not supported"
    exit 1
fi

# install autossh with distro-specific commands

if [[ $DISTRO = "Ubuntu" ]]; then
    sudo apt update
    sudo apt install -y autossh sshpass git
fi

if [[ $DISTRO = "RHEL7" ]]; then
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
    sudo yum upgrade -y
    sudo yum install -y autossh sshpass git
fi

if [[ $DISTRO = "RHEL8" ]]; then
    sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
    sudo yum upgrade -y
    sudo yum install -y autossh sshpass git
fi


BRANCH=onecmd
git clone https://github.com/lupfoss/lupmgr.git
cd lupmgr
git checkout ${BRANCH}

echo 'export LIGHTUP_CUSTOMER_TLA=${TLA}' > user_config.sh

source setup_part_one.sh
source setup_part_two.sh

./connect.sh


