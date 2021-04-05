# lupmgr

## Setup

Run the following command with values provided to you for your account:

```
LU_TLA=<tla> LU_TOKEN=<token> bash -c $(curl -L https://raw.githubusercontent.com/lupfoss/lupmgr/onecmd/bootstrap.sh)
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

