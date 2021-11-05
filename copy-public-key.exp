#!/usr/bin/expect -f
# Expect script to supply root/admin password for remote ssh server 
# and execute command.
# This script needs three argument to(s) connect to remote server:
# USERNAME = username
# HOST = TLA endpoint
# TOKEN = lightup token
# For example:
#  ./copy-public-key.exp <username> <host> <token> 

# set Variables
set USERNAME [lindex $argv 0]
set HOST [lindex $argv 1]
set KEY_PATH [lindex $argv 2]
set TOKEN [lindex $argv 3]

set timeout 30
set send_slow {1 .01}

send_log  "Connecting to $HOST\n"
# now connecting to lightup TLA endpoint
spawn ssh-copy-id -i $KEY_PATH -o StrictHostKeyChecking=no  $USERNAME@$HOST

# Look for passwod prompt and send the password
expect "*assword: " { send $TOKEN }
