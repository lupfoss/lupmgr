#!/usr/bin/env bash

set -e

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

