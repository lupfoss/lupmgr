#!/bin/bash

set -eu -o pipefail

# outside of repo - download init.sh
BRANCH=${LIGHTUP_BRANCH:-main}
curl -H 'Cache-Control: no-cache' -L https://raw.githubusercontent.com/lupfoss/lupmgr/$BRANCH/init.sh > init.sh
source init.sh
rm ../init.sh  # cleanup downloaded init.sh

if ! systemctl is-active --quiet lightup-ssh-connect ; then
    source connect_ssh_to_lightup.sh
else
    echo "lightup-ssh-connect service is already running"
fi

if ! systemctl is-active --quiet lightup-dataplane-connect ; then
    source connect_dataplane_to_lightup.sh
else
    echo "lightup-dataplane-connect service is already running"
fi

if [[ $INSTALL_DATAPLANE = "1" ]]; then
  echo "installing the Lightup dataplane..."
  source install-lightup.sh
else
  echo "Lightup dataplane install disabled"
fi

echo "you are all done here."
