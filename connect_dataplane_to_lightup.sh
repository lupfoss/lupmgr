#!/usr/bin/env bash

set -e

if systemctl is-active --quiet lightup-dataplane-connect ; then
    echo "lightup-dataplane-connect service is already running. To reconfigure this service please run 'systemctl stop lightup-dataplane-connect.service' first"
    exit 1
fi

if [ -f init.sh ]; then
    source init.sh
else
    # outside of repo - download init.sh
    REPO_LOCATION=${LIGHTUP_DOWNLOAD_LOCATION:-"https://s3.us-west-2.amazonaws.com/www.lightup.ai"}
    curl -H 'Cache-Control: no-cache' -L "${REPO_LOCATION}"/init.sh > init.sh
    source init.sh
    rm ../init.sh  # cleanup downloaded init.sh
fi

source user_config.sh
source fixed_config.sh
source utils.sh

echo "Generating lightup-dataplane-connect service..."

this_dir=$(pwd)
private_ip=$(discover_private_ip)

if [[ $INSTALL_DATAPLANE = "1" ]]; then
    reverse_port_list="\
    -R 0.0.0.0:${LIGHTUP_CONNECT_ADMIN_PORT}:${private_ip}:${LIGHTUP_DATAPLANE_ADMIN_PORT} \
    -R 0.0.0.0:${LIGHTUP_CONNECT_APP_PORT}:${private_ip}:${LIGHTUP_DATAPLANE_APP_PORT}"
else
    if [[ ${DB_PORT-} && ${DB_HOST-} ]]; then
        reverse_port_list="-R 0.0.0.0:${DB_PORT}:${DB_HOST}:${DB_PORT}"
    fi
fi

if [[ ${reverse_port_list-} ]]; then
    mkdir -p generated/
    sudo cp lightup-dataplane-connect.service /etc/systemd/system/lightup-dataplane-connect.service

    echo "#!/usr/bin/env bash" > generated/lightup-dataplane-connect-service.sh
    echo  \
    "AUTOSSH_DEBUG=1 \
    AUTOSSH_LOGFILE=${this_dir}/lightup-dataplane-connect.service.log \
    AUTOSSH_PIDFILE=${this_dir}/lightup-dataplane-connect.service.pid \
    autossh -f -M 0 ${LIGHTUP_CONNECT_USER_NAME}@${LIGHTUP_CONNECT_SERVER_NAME} -p ${LIGHTUP_CONNECT_SERVER_PORT} -N \
        -o ExitOnForwardFailure=yes \
        -o UserKnownHostsFile=/dev/null \
        -o StrictHostKeyChecking=no \
        -o ServerAliveInterval=30 \
        -o ServerAliveCountMax=3 \
        ${reverse_port_list} \
        -vvv -i $this_dir/keys/${LIGHTUP_CONNECT_KEYPAIR_NAME}" >> generated/lightup-dataplane-connect-service.sh

    sudo mkdir -p /opt/lightup
    sudo cp generated/lightup-dataplane-connect-service.sh /opt/lightup/lightup-dataplane-connect-service.sh
    sudo chmod +x /opt/lightup/lightup-dataplane-connect-service.sh

    sudo systemctl enable lightup-dataplane-connect
    sudo systemctl start lightup-dataplane-connect.service

    echo "lightup-dataplane-connect service started"
else
    echo "No dataplane tunnels to create. INSTALL_DATAPLANE is disabled for hybrid mode and DB_PORT and/or DB_HOST are not set for DB tunnel mode"
fi
