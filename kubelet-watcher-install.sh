#!/bin/bash

crontab -l
cp /home/ubuntu/lupmgr/kubelet-watcher /home/ubuntu/kubelet-watcher
chmod +x /home/ubuntu/kubelet-watcher
croncmd="/home/ubuntu/kubelet-watcher >> /home/ubuntu/kubelet-watcher.log 2>&1"
cronjob="* * * * * $croncmd"
( crontab -l | grep -v -F "$croncmd" ; echo "$cronjob" ) | crontab -
crontab -l
