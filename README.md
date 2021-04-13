# lupmgr

## Setup

Run the following command with values provided to you for your account:

```
LIGHTUP_TLA=<tla> LIGHTUP_TOKEN=<token> LIGHTUP_MGR_VERSION=<version> bash -c $(curl -L https://raw.githubusercontent.com/lupfoss/lupmgr/${LIGHTUP_MGR_VERSION}/bootstrap.sh)
```

E.g.: LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 LIGHTUP_MGR_VERSION=main
E.g.: LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 LIGHTUP_MGR_VERSION=onecmd
E.g.: LIGHTUP_TLA=dum LIGHTUP_TOKEN=e3976956-9ef0-44c5-a978-2ee9149e1234 LIGHTUP_MGR_VERSION=v0.2

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
