#!/bin/bash

set -eu -o pipefail

TOK=${LIGHTUP_TOKEN}
HA_INSTALL="${LIGHTUP_HA_INSTALL:-0}"
INSTALL_DATAPLANE="$(( ${LIGHTUP_INSTALL:-1} || HA_INSTALL ))"
LIGHTUP_CONNECT_ADMIN_PORT="${CONNECT_ADMIN_PORT:-8800}"
LIGHTUP_CONNECT_APP_PORT="${CONNECT_APP_PORT:-8443}"
LIGHTUP_CONNECT_MAPPED_PORT="${CONNECT_PORT:-9000}"
LIGHTUP_CONNECT_KEYPAIR_NAME="${LIGHTUP_TLA}-to-lightup-${HOSTNAME}-${LIGHTUP_CONNECT_MAPPED_PORT}"

# check user

if [ `whoami` = root ]; then
    echo "ERROR: Please do not run this script as root or using sudo"
    exit 1
else
    echo "User '`whoami`' will be used for the installation"
fi

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

if [[ -f /etc/os-release && $(grep -Eo 'Amazon Linux 2' /etc/os-release) ]]; then
    DISTRO="AL2"
fi

if [[ ${DISTRO-} = "" ]]; then
    echo "error: distro not supported, please see list of supported platforms at: "
    echo "https://docs.lightup.ai/lightup-quickstart/deployment/lightup-hybrid-quick-start#create-a-vm"
    exit 1
fi

# install autossh with distro-specific commands

if [[ $DISTRO = "Ubuntu" ]]; then
    sudo apt update

    #the following is needed because it looks like the replicated
    #installer is corrupting openssh packages and sending apt in a bad
    #state, so this script fails if run again after replicated unless
    #the following is executed.
    sudo apt --fix-broken install
    sudo apt install -y autossh sshpass git
fi

if [[ $DISTRO = "RHEL7" ]]; then
    rpm -qa | grep epel-release-7 || sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
    sudo yum upgrade -y
    sudo yum install -y autossh sshpass git
fi

if [[ $DISTRO = "RHEL8" ]]; then
    rpm -qa | grep epel-release-8 || sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
    sudo yum upgrade -y
    sudo yum install -y autossh sshpass git
fi

if [[ $DISTRO = "AL2" ]]; then
    # TODO: This could be combined with RHEL7
    # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/add-repositories.html
    rpm -qa | grep epel-release-7 || sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
    sudo yum upgrade -y
    sudo yum install -y autossh sshpass git
fi

# make user sudo passwordless to enable script runs
NAME=$(whoami)
if [[ ! -f lup-${NAME} ]]; then
    sudo echo "${NAME} ALL=(ALL) NOPASSWD: ALL" > lup-${NAME}
    sudo chmod 440 lup-${NAME}
    sudo chown root:root lup-${NAME}
    sudo cp lup-${NAME} /etc/sudoers.d/
fi

echo "export LIGHTUP_TLA=${LIGHTUP_TLA}" > user_config.sh
echo "export HA_INSTALL=${HA_INSTALL}" >> user_config.sh
echo "export INSTALL_DATAPLANE=${INSTALL_DATAPLANE}" >> user_config.sh
echo "export LIGHTUP_CONNECT_ADMIN_PORT=${LIGHTUP_CONNECT_ADMIN_PORT}" >> user_config.sh
echo "export LIGHTUP_CONNECT_APP_PORT=${LIGHTUP_CONNECT_APP_PORT}" >> user_config.sh
echo "export LIGHTUP_CONNECT_KEYPAIR_NAME=${LIGHTUP_CONNECT_KEYPAIR_NAME}" >> user_config.sh
echo "export LIGHTUP_CONNECT_MAPPED_PORT=${LIGHTUP_CONNECT_MAPPED_PORT}" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_USERNAME=$(whoami)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_LUPMGR_DIR=$(pwd)" >> user_config.sh
echo "export LIGHTUP_DATAPLANE_HOMEDIR=${HOME}" >> user_config.sh
source user_config.sh
source fixed_config.sh
source utils.sh

#----

mkdir -p keys

echo "generating new keypair to login to Lightup, name=${LIGHTUP_CONNECT_KEYPAIR_NAME}"
if [[ ! -f /opt/lightup/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} ]]; then
  ssh-keygen -t rsa -b 4096 -N "" -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}
  sshpass -p ${TOK} ssh-copy-id -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub -o StrictHostKeyChecking=no ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}
  sudo mkdir -p /opt/lightup
  sudo cp -r ./keys/ /opt/lightup/
  # copy the public key back to the connect VM for backup / disaster recovery
  sudo scp -o "StrictHostKeyChecking no" -i /opt/lightup/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} /opt/lightup/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub"
else
  echo "keypair already exists, skipping..."
fi

# key setup
echo "adding Lightup's public key to authorized keys..."
sudo scp -o "StrictHostKeyChecking no" -i /opt/lightup/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" ./keys/
mkdir -p ~/.ssh && cat "/opt/lightup/keys/${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" >> ~/.ssh/authorized_keys

