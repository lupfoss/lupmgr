# set the following field
export LIGHTUP_CUSTOMER_TLA="<value>"

# leave those fields as they are
export LIGHTUP_CONNECT_KEYPAIR_NAME="${LIGHTUP_CUSTOMER_TLA}-to-lightup"
export LIGHTUP_ACCEPT_KEYPAIR_NAME="lightup-to-${LIGHTUP_CUSTOMER_TLA}"
export LIGHTUP_CONNECT_SERVER_NAME="connect.${LIGHTUP_CUSTOMER_TLA}.lightup.ai"
export LIGHTUP_CONNECT_SERVER_PORT=22
export LIGHTUP_CONNECT_USER_NAME="ubuntu"
