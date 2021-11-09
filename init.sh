#!/bin/bash -xe

set -eu -o pipefail

TOK=${LIGHTUP_TOKEN}
BRANCH=${LIGHTUP_BRANCH:-main}
INSTALL_DATAPLANE="${LIGHTUP_INSTALL:-1}"
LIGHTUP_CONNECT_MAPPED_PORT="${CONNECT_PORT:-9000}"
LIGHTUP_CONNECT_KEYPAIR_NAME="${LIGHTUP_TLA}-to-lightup-${HOSTNAME}-${LIGHTUP_CONNECT_MAPPED_PORT}"


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
    echo "Detected Amazon Linux 2"
    sudo yum upgrade -y
    sudo yum install -y expect git
fi

# make user sudo passwordless to enable script runs
NAME=$(whoami)
if [[ ! -f lup-${NAME} ]]; then
    sudo echo "${NAME} ALL=(ALL) NOPASSWD: ALL" > lup-${NAME}
    sudo chmod 440 lup-${NAME}
    sudo chown root:root lup-${NAME}
    sudo cp lup-${NAME} /etc/sudoers.d/
fi

[[ -d lupmgr ]] || git clone https://github.com/lupfoss/lupmgr.git
cd lupmgr && git pull && git checkout ${BRANCH}

echo "export LIGHTUP_TLA=${LIGHTUP_TLA}" > user_config.sh
echo "export INSTALL_DATAPLANE=${INSTALL_DATAPLANE}" >> user_config.sh
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
if [[ ! -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}]]; then
  echo "Using EXPECT to copy the key over"
  ssh-keygen -t rsa -b 4096 -N "" -f ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}

else
  echo "keypair already exists, skipping..."
fi

echo "Copying public key over to control plane"
if [[ $DISTRO = "AL2" ]]; then
  echo "Using EXPECT to copy the key over"
  expect <<'END_EXPECT'
          spawn ssh-copy-id -i $env(HOME)/lupmgr/keys/$env(LIGHTUP_CONNECT_KEYPAIR_NAME) $env(LIGHTUP_CONNECT_USER_NAME)@$env(LIGHTUP_CONNECT_SERVER_NAME) -o StrictHostKeyChecking=no
          expect -re "Password: "
          send_user "TOKEN: $env(LIGHTUP_TOKEN)"
          send -- "$env(LIGHTUP_TOKEN)\r"
          expect eof
END_EXPECT

else
  echo "Using SSHPASS to copy the key over"
  sshpass -p ${TOK} ssh-copy-id -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}.pub -o StrictHostKeyChecking=no ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}

fi


# key setup
echo "adding Lightup's public key to authorized keys..."
scp -o "StrictHostKeyChecking no" -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" ./keys/
mkdir -p ~/.ssh && cat "./keys/${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" >> ~/.ssh/authorized_keys

echo "finished the init"