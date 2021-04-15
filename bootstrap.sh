#!/bin/bash

#set -x
set -eu -o pipefail

TLA=${LIGHTUP_TLA}
TOK=${LIGHTUP_TOKEN}
BRANCH=${LIGHTUP_BRANCH:-main}



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

    #MB: the following is needed because it looks like the replicated 
    #installer is corrupting openssh packages and sending apt in a bad
    #state, so this script fails if run again after replicated unless
    #the following is executed.
    sudo apt --fix-broken install

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


[[ -d lupmgr ]] || git clone https://github.com/lupfoss/lupmgr.git
cd lupmgr && git pull && git checkout ${BRANCH}

echo "export LIGHTUP_CUSTOMER_TLA=${TLA}" > user_config.sh
echo "export LIGHTUP_DATAPLANE_USERNAME=$(whoami)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_LUPMGR_DIR=$(pwd)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_HOMEDIR=${HOME}" >> user_config.sh
source user_config.sh
source fixed_config.sh
source utils.sh

#----


mkdir -p keys

echo "generating new keypair to login to Lightup, name=${LIGHTUP_CONNECT_KEYPAIR_NAME}"
if [[ ! -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} ]]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}
else
  echo "keypair already exists, skipping..."
fi

#echo; echo "please share the following public key with Lightup (./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub):"; echo
#cat ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub
pwd
sshpass -p ${TOK} ssh-copy-id -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub -o StrictHostKeyChecking=no ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}

#----


# key setup
echo "adding Lightup's public key to authorized keys..."
scp -o "StrictHostKeyChecking no" -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" ./keys/
mkdir -p ~/.ssh && cat "./keys/${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" >> ~/.ssh/authorized_keys

# rc.local setup
mkdir -p generated/
sudo cp rc-local.service /etc/systemd/system/rc-local.service
echo "#!/usr/bin/env bash" > generated/rc.local.tmp
./generate_command.sh >> generated/rc.local.tmp
sudo cp generated/rc.local.tmp /etc/rc.local
sudo chmod +x /etc/rc.local

sudo systemctl enable rc-local
sudo systemctl start rc-local.service 
#sudo systemctl status rc-local.service || true

#----

source disconnect.sh
source connect.sh
echo

#----

echo "installing the Lightup dataplane..."
source install-lightup.sh

#----
echo "you are all done here."
