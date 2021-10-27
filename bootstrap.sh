#!/bin/bash

#set -x
set -eu -o pipefail

source init.sh

if ! systemctl is-active --quiet service ; then
    source connect_ssh_to_lightup.sh
fi

#----

#source disconnect.sh
#source connect.sh
#echo

#----

if [[ $INSTALL_DATAPLANE = "1" ]]; then
  echo "installing the Lightup dataplane..."
  source install-lightup.sh
fi

#----
echo "you are all done here."
