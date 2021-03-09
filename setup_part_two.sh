#!/usr/bin/env bash

source user_config.sh
source fixed_config.sh

# key setup
echo "adding Lightup's public key to authorized keys..."
scp -i ./keys/${LIGHTUP_CONNECT_KEYPAIR_NAME} -P ${LIGHTUP_CONNECT_SERVER_PORT} ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME}:~/"${LIGHTUP_ACCEPT_KEYPAIR_NAME}.pub" ./keys/
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
sudo systemctl status rc-local.service
