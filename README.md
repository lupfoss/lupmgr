# sshagent

## Setup

Clone this repository on the target VM:

```
git clone https://github.com/lupfoss/sshagent.git
cd sshagent
```

Copy sample config file to a config file that you will modify:
```
cp sample_config.sh config.sh
```

Now, set up values in `config.sh` using instructions received from Lightup.
You should only need to set the following field:

```
export LIGHTUP_CUSTOMER_TLA="<value>"
```



From the repository folder, run the first part of the setup sequence:
```
./setup_part_one.sh
```

Communicate the public key listed and pasted at the end of `setup_part_one.sh`
to Lightup:

```
# send public key to Lightup
```

After getting a go-ahead from Lightup to proceed to part two of setup, run the following:

```
./setup_part_two.sh
```

## Start

Now start the ssh agent using:

```
./connect.sh
```

## Stop

At any point, stop the ssh agent using:

```
./disconnect.sh
```

Stopping the agent will take away access from Lightup.
