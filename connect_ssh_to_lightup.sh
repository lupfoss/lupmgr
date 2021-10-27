#!/usr/bin/env bash

set -e

source init.sh
source user_config.sh
source fixed_config.sh

this_dir=$(pwd)

mkdir -p generated/
sudo cp lightup-ssh-connect.service /etc/systemd/system/lightup-ssh-connect.service

echo "#!/usr/bin/env bash" > generated/lightup-ssh-connect-service.sh
echo  \
"AUTOSSH_DEBUG=1 \
AUTOSSH_LOGFILE=${this_dir}/lightup-ssh-connect.service.log \
AUTOSSH_PIDFILE=${this_dir}/lightup-ssh-connect.service.pid \
autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
    -o ExitOnForwardFailure=yes \
    -o UserKnownHostsFile=/dev/null \
    -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -R ${LIGHTUP_CONNECT_MAPPED_PORT}:localhost:22 \
    -vvv -i $this_dir/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}" >> generated/lightup-ssh-connect-service.sh

sudo mkdir -p /opt/lightup
sudo cp generated/lightup-ssh-connect-service.sh /opt/lightup/lightup-ssh-connect-service.sh
sudo chmod +x /opt/lightup/lightup-ssh-connect-service.sh

sudo systemctl enable lightup-ssh-connect
sudo systemctl start lightup-ssh-connect.service
#sudo systemctl status lightup-ssh-connect.service || true
