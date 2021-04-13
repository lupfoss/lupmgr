# lupmgr

## Setup

Run the following commands with values provided to you for your account:

```
curl -H 'Cache-Control: no-cache' -L https://raw.githubusercontent.com/lupfoss/lupmgr/v0.2/bootstrap.sh > bootstrap.sh && chmod +x bootstrap.sh
LIGHTUP_TLA=<tla> LIGHTUP_TOKEN=<token> ./bootstrap.sh
```

Examples:

```
curl -H ...
LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 ./bootstrap.sh

curl -H ...
LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 ./bootstrap.sh

curl -H ...
LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 ./bootstrap.sh
```

## Troubleshooting and Overrides

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
