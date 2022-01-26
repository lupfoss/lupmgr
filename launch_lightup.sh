#!/bin/bash

set -e

BRANCH=${LIGHTUP_BRANCH:-main}
DOWNLOAD_LOCATION=${LIGHTUP_DOWNLOAD_LOCATION:-"https://s3.us-west-2.amazonaws.com/www.lightup.ai/releases/lupmgr"}
RELEASE=${LIGHTUP_RELEASE:-"latest"}

# DOWNLOAD_LOCATION options are: a URL to download the repo, "git" to clone the repo, or
# "local" for an already downloaded repo
if [[ $DOWNLOAD_LOCATION = "git" ]]; then
    echo "Cloning Lightup Manager"
    [[ -d lupmgr ]] && rm -rf lupmgr
    git clone https://github.com/lupfoss/lupmgr.git
    cd lupmgr && git pull && git checkout ${BRANCH}
elif [[ $DOWNLOAD_LOCATION != "local" ]]; then
    echo "Downloading Lightup Manager..."
    curl -H 'Cache-Control: no-cache' -L "${DOWNLOAD_LOCATION}"/"${RELEASE}/lupmgr.tar.gz" --output lupmgr.tar.gz
    tar -xvf lupmgr.tar.gz
    [[ -d lupmgr ]] && rm -rf lupmgr
    mv lupmgr-* lupmgr
    cd lupmgr
fi

case $1 in
    install) source bootstrap.sh
    ;;
    connect_ssh_to_lightup) source connect_ssh_to_lightup.sh
    ;;
    connect_dataplane_to_lightup) source connect_dataplane_to_lightup.sh
    ;;
    "") echo "Lightup Manager downloaded to: $(pwd)"
    ;;
    *)
    echo "unknown command: $1"
    ;;
esac
