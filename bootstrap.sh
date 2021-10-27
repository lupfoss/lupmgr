#!/bin/bash

set -eu -o pipefail

source init.sh

if ! systemctl is-active --quiet lightup-ssh-connect ; then
    source connect_ssh_to_lightup.sh
fi

if ! systemctl is-active --quiet lightup-dataplane-connect ; then
    source connect_dataplane_to_lightup.sh
fi

if [[ $INSTALL_DATAPLANE = "1" ]]; then
  echo "installing the Lightup dataplane..."
  source install-lightup.sh
fi

echo "you are all done here."
