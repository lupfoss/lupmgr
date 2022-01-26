# Lightup Agent Manager

## Setup

Run the following commands with values provided to you for your account:

```
curl -H 'Cache-Control: no-cache' -L https://s3.us-west-2.amazonaws.com/www.lightup.ai/launch_lightup.sh | LIGHTUP_TLA=<tla> LIGHTUP_TOKEN=<token> bash -s install
```

Examples:

```
# Install Lightup tunnel and dataplane
LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 ./bootstrap.sh

# Install only the Lightup tunnel
LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 LIGHTUP_INSTALL=0 ./bootstrap.sh
```

## Troubleshooting and Overrides

### Proxy Support

If tunnel needs to be run through an HTTP/HTTPS proxy

1. Update `LIGHTUP_CONNECT_SERVER_PORT` in fixed_config.sh to indicate either 80 or 443 based on the type of proxy.
2. Run the `proxy.sh` script with the appropriate environment variables (Required: PROXY_HOST, PROXY_PORT. Optional: PROXY_USER, PROXY_PASSWORD)

Example:
```
LIGHTUP_TLA=dum PROXY_HOST=proxy.dum.com PROXY_PORT=8192 ./proxy.sh
```

### Start

Start the Lightup manager using:

```
./connect.sh
```

### Stop

Stop the Lightup manager using:

```
./disconnect.sh
```

Stopping the Lightup manager will take away access from Lightup.


### Uninstall

Clean out the setup:

```
./uninstall.sh
```
